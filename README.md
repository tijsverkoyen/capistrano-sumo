# Capistrano::Sumo

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/capistrano/sumo`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-sumo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-sumo

## Usage

# Capistrano::Forkcms

Fork CMS specific Capistrano tasks

Capistrano ForkCMS - Easy deployment of ForkCMS 5+ apps with Ruby over SSH.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-forkcms'
```

And then execute:

    $ bundle


## Usage

Require the module in your Capfile:

    require "capistrano/sumo"
    
The plugin comes with some tasks:

* `sumo:db:create`, which will create the database if it doesn't exists yet, works only on staging.
* `sumo:db:get`, which will replace the local database with the remote database.
* `sumo:db:info`, which will get info about the database, works only on staging.
* `sumo:db:put`, which will replace the remote database with the local database.
* `sumo:files:get`, which will downloads the remote files to the local instance.
* `sumo:files:put`, which will upload the local files to the remote server.
* `sumo:notifications:deploy`, which will notify our webhooks on a deploy.
* `sumo:redirect:enable`, which will enable a redirect page, all traffic will be redirected to this page.

But you won't need any of them as everything is wired automagically if you follow the steps below


## Configuration

Configuration options:

...

## How to use with a fresh Fork install

1. Create a Capfile with the content below:

```
set :deploy_config_path, 'app/config/capistrano/deploy.rb'
set :stage_config_path, 'app/config/capistrano/stages'

require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git
require 'capistrano/forkcms'
require 'capistrano/sumo'
require 'capistrano/deploytags'

set :format_options, log_file: 'app/logs/capistrano.log'

Dir.glob('app/config/capistrano/tasks/*.rake').each { |r| import r }
```

2. Create a file called `app/config/capistrano/deploy.rb`, with the content below:

```
set :client,  "$the-clients-name"
set :project, "$the-project-name"
set :repo_url, "$the-repo-url"
set :production_url, "$the-production-url"

### DO NOT EDIT BELOW ###
set :application, "#{fetch :project}"

set :deploytag_utc, false
set :deploytag_time_format, "%Y%m%d-%H%M%S"

set :files_dir, %w(src/Frontend/Files)
```

3. Create a file called `app/config/capistrano/stages/production.rb`, with the content below:

```
server "php71-001.sumohosting.be", user: "$production-user", roles: %w{app db web}

set :document_root, "/home/$production-user/domains/$domain/public_html"
set :deploy_to, "/home/$production-user/apps/#{fetch :project}"

set :opcache_reset_strategy, "fcgi"
set :opcache_reset_fcgi_connection_string, "/usr/local/php71/sockets/$production-user.sock"

### DO NOT EDIT BELOW ###
set :keep_releases, 3
set :php_bin, "php"

SSHKit.config.command_map[:composer] = "#{fetch :php_bin} #{shared_path.join("composer.phar")}"
SSHKit.config.command_map[:php] = fetch(:php_bin)
```

4. Create a file called `app/config/capistrano/stages/staging.rb`, with the content below:

```

### DO NOT EDIT BELOW ###
set :branch, "staging"
set :document_root, "/home/sites/php71/#{fetch :client}/#{fetch :project}"
set :deploy_to, "/home/sites/apps/#{fetch :client}/#{fetch :project}"
set :keep_releases,  2
set :url, "http://#{fetch :project}.#{fetch :client}.php71.sumocoders.eu"
set :fcgi_connection_string, "/var/run/php_71_fpm_sites.sock"
set :php_bin, "php7.1"
set :php_bin_custom_path, fetch(:php_bin)
set :opcache_reset_strategy, "fcgi"
set :opcache_reset_fcgi_connection_string, "/var/run/php_71_fpm_sites.sock"

server "dev02.sumocoders.eu", user: "sites", roles: %w{app db web}

SSHKit.config.command_map[:composer] = "#{fetch :php_bin} #{shared_path.join("composer.phar")}"
SSHKit.config.command_map[:php] = fetch(:php_bin)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/tijsverkoyen/capistrano-sumo/issues](https://github.com/tijsverkoyen/capistrano-cachetool/issues).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
