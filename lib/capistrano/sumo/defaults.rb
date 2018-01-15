require 'json'

namespace :deploy do
  package = JSON.parse(File.read('composer.json'))

  # compile and upload the assets, but only if it's a Fork CMS project
  after :updated, 'sumo:assets:put' if package['name'] == 'forkcms/forkcms'

  # notify our bot about the deploy
  after :finished, 'sumo:notifications:deploy'
end

# Load the tasks
load File.expand_path('../../tasks/assets.rake', __FILE__)
load File.expand_path('../../tasks/db.rake', __FILE__)
load File.expand_path('../../tasks/files.rake', __FILE__)
load File.expand_path('../../tasks/notifications.rake', __FILE__)
load File.expand_path('../../tasks/redirect.rake', __FILE__)
