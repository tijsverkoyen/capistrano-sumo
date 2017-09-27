namespace :deploy do
  # compile and upload the assets
  after :updated, 'sumo:assets:put'
  after :updated, 'sumo:migrations:prepare'
  after :updated, 'sumo:migrations:execute'

  # notify our bot about the deploy
  after :finished, 'sumo:notifications:deploy'

  # in case something goes wrong and we have to rollback, initialize the migrations rollback
  after :reverted, 'sumo:migrations:rollback'
end

# Load the tasks
load File.expand_path('../../tasks/assets.rake', __FILE__)
load File.expand_path('../../tasks/db.rake', __FILE__)
load File.expand_path('../../tasks/files.rake', __FILE__)
load File.expand_path('../../tasks/migrations.rake', __FILE__)
load File.expand_path('../../tasks/notifications.rake', __FILE__)
load File.expand_path('../../tasks/redirect.rake', __FILE__)
