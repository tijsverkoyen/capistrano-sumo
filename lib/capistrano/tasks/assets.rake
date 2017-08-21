namespace :sumo do
  namespace :assets do
    desc 'Compile the assets'
    task :compile do
      run_locally do
        execute :gulp, '--silent', 'build:theme'
      end
    end

    desc 'Uploads the build assets to the remote server'
    task :put do
      invoke 'sumo:assets:compile'
    end
  end
end