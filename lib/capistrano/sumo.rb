require 'rake'
require 'capistrano/sumo/version'

namespace :load do
  task :defaults do
    load 'capistrano/sumo/defaults.rb'
  end
end