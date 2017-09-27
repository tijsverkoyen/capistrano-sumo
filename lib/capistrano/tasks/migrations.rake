namespace :sumo do
  namespace :migrations do
    desc 'prepares the server for running fork migrations'
    task :prepare do
      on roles(:web) do
        # Check if the migrations file exists.
        migrationsFileExists = capture("if [ -f #{shared_path}/executed_migrations ]; then echo 'yes'; fi").chomp

        # Only create the file if it doesn't exists.
        unless migrationsFileExists == 'yes'
          # Create an empty executed_migrations file
          upload! StringIO.new(''), "#{shared_path}/executed_migrations"
        end

        # Check if the maintenance folder exists.
        maintenanceFolderExists = capture("if [ -d #{shared_path}/maintenance ]; then echo 'yes'; fi").chomp

        # Only create the maintenance folder if it doesn't exist
        unless maintenanceFolderExists == 'yes'
          local_maintenance_path = File.dirname(__FILE__)
          local_maintenance_path = "#{local_maintenance_path}/../../maintenance"

          # Create a maintenance folder containing the index page from our gem
          execute :mkdir, "#{shared_path}/maintenance"

          # copy the contents of the index.html file to our shared folder
          upload! File.open(local_maintenance_path + '/index.html'), "#{shared_path}/maintenance/index.html"

          # copy the contents of the .htaccess file to our shared folder
          upload! File.open(local_maintenance_path + '/.htaccess'), "#{shared_path}/maintenance/.htaccess"
        end
      end
    end

    desc 'fills in the executed_migrations on first deploy'
    task :first_deploy do
      on roles(:web) do
        # Put all items in the migrations folder in the executed_migrations file
        # When doing a deploy:setup, we expect the database to already contain
        # The migrations (so a clean copy of the database should be available
        # when doing a setup)
        folders = capture("if [ -e #{release_path}/migrations ]; then ls -1 #{release_path}/migrations; fi").split(/\r?\n/)

        folders.each do |dirname|
          run "echo #{dirname} | tee -a #{shared_path}/executed_migrations"
        end
      end
    end

    desc 'runs the migrations'
    task :execute do
      on roles(:web) do
        # If the current symlink doesn't exist yet, we're on a first deploy
        currentDirectoryExists = capture("if [ ! -e #{current_path} ]; then echo 'yes'; fi").chomp
        if currentDirectoryExists == 'yes'
          invoke 'sumo:migrations:first_deploy'
        end

        # Check if there are new migrations found
        folders = capture("if [ -e #{release_path}/migrations ]; then ls -1 #{release_path}/migrations; fi").split(/\r?\n/)

        if folders.length > 0
          executedMigrations = capture("cat #{shared_path}/executed_migrations").chomp.split(/\r?\n/)
          migrationsToExecute = Array.new

          # Fetch all migration directories that aren't executed yet
          folders.each do |dirname|
            migrationsToExecute.push(dirname) if executedMigrations.index(dirname) == nil
          end

          if migrationsToExecute.length > 0
            # This can take a while and can go wrong. let's show a maintenance page
            # and make sure we can put back the database
            invoke 'sumo:migrations:symlink_maintenance'
            invoke 'sumo:migrations:backup_database'

            # run all migrations
            migrationsToExecute.each do |dirname|
              migrationpath = "#{release_path}/migrations/#{dirname}"
              migrationFiles = capture("ls -1 #{migrationpath}").split(/\r?\n/)

              migrationFiles.each do |filename|
                if filename.index('locale.xml') != nil
                  execute :php, "#{release_path}/bin/console forkcms:locale:import -f #{migrationpath}/#{filename}"
                end

                if filename.index('update.php') != nil
                  execute :php, "#{migrationpath}/#{filename}"
                end

                if filename.index('update.sql') != nil
                  set :mysql_update_file, "#{migrationpath}/#{filename}"
                  invoke 'sumo:migrations:mysql_update'
                end
              end
            end

            # all migrations where executed successfully, put them in the
            # executed_migrations file
            migrationsToExecute.each do |dirname|
              execute "echo #{dirname} | tee -a #{shared_path}/executed_migrations"
            end

            # symlink the root back
            invoke 'sumo:migrations:symlink_root'
          end
        end
      end
    end

    desc 'shows a maintenance page'
    task :symlink_maintenance do
      on roles(:web) do
        execute :rm, '-rf', "#{fetch :document_root} && ln -sf #{shared_path}/maintenance #{fetch :document_root}"
      end
    end

    desc 'Symlink back the document root with the current deployed version.'
    task :symlink_root do
      on roles(:web) do
        execute :rm, '-rf', "#{fetch :document_root} && ln -sf #{current_path} #{fetch :document_root}"
      end
    end

    desc 'backs up the database'
    task :backup_database do
      on roles(:web) do
        parametersContent = capture "cat #{shared_path}/app/config/parameters.yml"
        yaml = YAML::load(parametersContent.gsub("%", ""))
        execute :mysqldump,
          "--skip-lock-tables",
          "--default-character-set='utf8'",
          "--host=#{yaml['parameters']['database.host']}",
          "--port=#{yaml['parameters']['database.port']}",
          "--user=#{yaml['parameters']['database.user']}",
          "--password=#{yaml['parameters']['database.password']}",
          "#{yaml['parameters']['database.name']}",
          "> #{release_path}/mysql_backup.sql"
      end
    end

    desc 'puts back the database'
    task :rollback do
      on roles(:web) do
        set :mysql_update_file, '#{release_path}/mysql_backup.sql'
        invoke 'sumo:migrations:mysql_update'

        invoke 'sumo:migrations:symlink_root'
      end
    end

    desc 'updates mysql with a certain (sql) file'
    task :mysql_update do
      on roles(:web) do
        parametersContent = capture "cat #{shared_path}/app/config/parameters.yml"
        yaml = YAML::load(parametersContent.gsub("%", ""))

        execute :mysql,
          "--default-character-set='utf8'",
          "--host=#{yaml['parameters']['database.host']}",
          "--port=#{yaml['parameters']['database.port']}",
          "--user=#{yaml['parameters']['database.user']}",
          "--password=#{yaml['parameters']['database.password']}",
          "#{yaml['parameters']['database.name']}",
          "< #{fetch :mysql_update_file}"
      end
    end
  end
end
