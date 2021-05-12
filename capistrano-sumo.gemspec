# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capistrano/sumo/version"

Gem::Specification.new do |spec|
  spec.name = 'capistrano-sumo'
  spec.version = Capistrano::Sumo::VERSION
  spec.authors = ['Tijs Verkoyen']
  spec.email = ['capistrano-sumo@verkoyen.eu']

  spec.summary = %q{SumoCoders specific task for Capistrano 3.x.}
  spec.description = %q{SumoCoders specific task for Capistrano 3.x.}
  spec.homepage = 'https://github.com/tijsverkoyen/capistrano-sumo'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
end
