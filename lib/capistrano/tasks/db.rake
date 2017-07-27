namespace :sumo do
  namespace :db do
    desc "Create the database if it doesn't exists yet"
    task :create do
      if fetch(:stage).to_s != "staging"
        warn Airbrussh::Colors.red('✘') + " This task will only work on staging"
        exit 1
      end

      on roles(:web) do
        execute "create_db #{(fetch :client)[0, 8]}_#{(fetch :project)[0, 7]}"
      end
    end

    desc "Get info about the database"
    task :info do
      if fetch(:stage).to_s != "staging"
        warn Airbrussh::Colors.red('✘') + " This task will only work on staging"
        exit 1
      end

      on roles(:web) do
        execute "info_db #{(fetch :client)[0, 8]}_#{(fetch :project)[0, 7]}"
      end
    end

    desc "Replace the remote database with the local database"
    task :put do
      on roles(:db) do
        execute :mysqldump, "--lock-tables=false --set-charset #{remote_db_options} #{extract_from_remote_parameters('database.name')} > #{shared_path}/backup_#{Time.now.strftime('%Y%m%d%H%M')}.sql"
      end

      run_locally do
        execute :mysqldump, "--lock-tables=false --set-charset #{extract_from_local_parameters('database.name')} > ./db_upload.tmp.sql"
      end

      on roles(:db) do
        upload! File.open('./db_upload.tmp.sql'), "#{shared_path}/db_upload.tmp.sql"
        execute :mysql, "#{remote_db_options} #{extract_from_remote_parameters('database.name')} < #{shared_path}/db_upload.tmp.sql"
        execute :rm, "#{shared_path}/db_upload.tmp.sql"
      end

      run_locally do
        execute :rm, './db_upload.tmp.sql'
      end
    end

    ## Some helper methods
    private
    def remote_db_options
      data = {
          'host' => extract_from_remote_parameters("database.host"),
          'user' => extract_from_remote_parameters("database.user"),
          'password' => extract_from_remote_parameters("database.password"),
      }
      options = ''

      data.each do |key, value|
        options << "--#{key}=#{value} " unless value.empty?
      end
      options
    end

    def extract_from_local_parameters(key)
      data = IO.read('./app/config/parameters.yml')
      extract_from_parameters(key, data)
    end

    def extract_from_remote_parameters(key)
      data = capture("cat #{shared_path}/app/config/parameters.yml")
      extract_from_parameters(key, data)
    end

    def extract_from_parameters(key, data)
      # It seems we use invalid yml in our config files
      # Therefore we need to fix some issues with it.
      data = data.gsub(/:(\s*)%(.*)/, ':\1"%\2"')

      config = YAML::load(data)
      config.fetch('parameters').fetch(key)
    end
  end
end
