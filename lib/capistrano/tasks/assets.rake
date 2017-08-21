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
        path = "/src/Frontend/Themes/#{theme}/Core"

        # upload compiled theme
        upload! ".#{path}", "#{current_path}#{File.dirname(path)}", recursive: true
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