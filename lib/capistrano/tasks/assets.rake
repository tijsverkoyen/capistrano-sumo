require 'json'

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
      on roles(:web) do
        remote_path = "#{release_path}/src/Frontend/Themes/#{theme}/Core"

        # delete old folder
        execute :rm, '-rf', remote_path
        execute :mkdir, '-p', remote_path

        # upload compiled theme
        upload! "./src/Frontend/Themes/#{theme}/Core", "#{File.dirname(remote_path)}", recursive: true
      end
    end

    def theme
      package = JSON.parse(File.read('package.json'))

      if not package.key?('theme')
        warn Airbrussh::Colors.red('✘') + ' No theme available in package.json.'
        exit 1
      end

      package['theme']
    end
  end
end