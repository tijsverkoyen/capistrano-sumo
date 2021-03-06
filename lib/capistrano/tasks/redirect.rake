namespace :sumo do
  namespace :redirect do
    desc 'Enable a redirect page, all traffic will be redirected to this page.'
    task :enable do
      on roles(:web) do
        execute :mkdir, '-p', "#{shared_path}/redirect"
        execute :wget, '-qO', "#{shared_path}/redirect/index.php http://static.sumocoders.be/redirect2/index.phps"
        execute :wget, '-qO', "#{shared_path}/redirect/.htaccess http://static.sumocoders.be/redirect2/htaccess"
        execute :sed, '-i', "'s|<real-url>|#{fetch :production_url}|' #{shared_path}/redirect/index.php"
        execute :rm, '-f', "#{fetch :deploy_to}/current"
        execute :ln, '-s', "#{shared_path}/redirect #{fetch :deploy_to}/current"
      end
    end
  end
end
