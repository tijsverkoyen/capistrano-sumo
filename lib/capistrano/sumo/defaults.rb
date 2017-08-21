namespace :deploy do
  # notify our bot about the deploy
  after :finished, 'sumo:notifications:deploy'
end

# Load the tasks
load File.expand_path('../../tasks/assets.rake', __FILE__)
load File.expand_path('../../tasks/db.rake', __FILE__)
load File.expand_path('../../tasks/files.rake', __FILE__)
load File.expand_path('../../tasks/notifications.rake', __FILE__)
load File.expand_path('../../tasks/redirect.rake', __FILE__)
