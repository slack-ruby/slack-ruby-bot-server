ENV['RACK_ENV'] ||= 'development'

Bundler.require :default

require_relative 'commands'
require 'yaml'

ActiveRecord::Base.establish_connection(YAML.load_file('config/postgresql.yml')[ENV['RACK_ENV']])

NewRelic::Agent.manual_start

SlackRubyBotServer::App.instance.prepare!
SlackRubyBotServer::Service.start!

run SlackRubyBotServer::Api::Middleware.instance
