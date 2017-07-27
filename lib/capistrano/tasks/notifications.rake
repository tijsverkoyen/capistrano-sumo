namespace :sumo do
  namespace :notifications do
    desc "Notify our webhooks on a deploy"
    task :deploy do
      on roles(:web) do
        execute :curl,
                "-sS",
                "--data local_username=#{ENV["USER"]}",
                "--data stage=#{fetch(:stage)}",
                "--data repo=#{fetch(:repo_url)}",
                "--data revision=#{capture("cat #{current_path}/REVISION")}",
                "http://bot.sumo.sumoapp.be:3001/deploy/hook"
      end
    end
  end
end