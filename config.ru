require_relative 'config/environment'

if ENV['RACK_ENV'] == 'development'
  puts 'Loading NewRelic in developer mode ...'
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
end

NewRelic::Agent.manual_start

SlackBotServer::App.instance.prepare!
SlackBotServer::Service.start!

run SlackBotServer::Api::Middleware.instance
