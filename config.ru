$:.unshift File.expand_path('../lib', __FILE__)
require 'tomb'

Tomb::App.set :artifacts, File.expand_path('../artifacts', __FILE__)
Tomb::App.set :user_list, File.expand_path('../users.yml', __FILE__)
Tomb::App.set :github_options, {
  scopes:       'user',
  secret:       ENV.fetch('GITHUB_SECRET'),
  client_id:    ENV.fetch('GITHUB_CLIENT_ID'),
  organization: ENV.fetch('GITHUB_ORGANIZATION')
}
run Tomb::App
