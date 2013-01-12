require 'rubygems'
require 'bundler'
Bundler.require

$:.unshift File.expand_path('../lib', __FILE__)
require 'tomb'
Tomb::App.set :root, File.expand_path('..', __FILE__)
Tomb::App.set :scss, load_paths: [
  File.join(Bundler.load.specs.find { |s| s.name == 'bourbon' }.full_gem_path, 'app', 'assets', 'stylesheets')
]
run Tomb::App
