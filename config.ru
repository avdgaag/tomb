require 'rubygems'
require 'bundler'
Bundler.require

$:.unshift File.expand_path('../lib', __FILE__)
require 'tomb'
Tomb::App.set :root,      File.expand_path('..',           __FILE__)
Tomb::App.set :artifacts, File.expand_path('../artifacts', __FILE__)
Tomb::App.set :user_list, File.expand_path('../users.yml', __FILE__)
Tomb::App.set :github_options, {
  scopes:       'user',
  secret:       'acb5ca6fc2cf909aed003669bac35860f59df91d',
  client_id:    '6bc0b2867a6abacbd961',
  organization: 'kabisaict'
}

Tomb::App.set :scss, load_paths: [
  File.join(Bundler.load.specs.find { |s| s.name == 'bourbon' }.full_gem_path, 'app', 'assets', 'stylesheets')
]
run Tomb::App
