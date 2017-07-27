# Make sure the composer executable is installed
namespace :deploy do
  after :finished, "sumo:notifications:deploy"
end

# Load the tasks
load File.expand_path('../../tasks/db.rake', __FILE__)
load File.expand_path('../../tasks/files.rake', __FILE__)
load File.expand_path('../../tasks/notifications.rake', __FILE__)
load File.expand_path('../../tasks/redirect.rake', __FILE__)
