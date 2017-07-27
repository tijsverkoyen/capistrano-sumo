require 'rake'
require 'capistrano/sumo/version'

load File.expand_path('../tasks/db.rake', __FILE__)
load File.expand_path('../tasks/notifications.rake', __FILE__)
load File.expand_path('../tasks/redirect.rake', __FILE__)
