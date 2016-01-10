ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require :default, ENV['RACK_ENV']

Dir[File.expand_path('../config/initializers', __FILE__) + '/**/*.rb'].each do |file|
  require file
end

Mongoid.load! File.expand_path('../config/mongoid.yml', __FILE__), ENV['RACK_ENV']

require 'faye/websocket'
require 'slack-ruby-bot'
require 'slack-bot-server/version'
require 'slack-bot-server/info'
require 'slack-bot-server/models'
require 'slack-bot-server/api'
require 'slack-bot-server/app'
require 'slack-bot-server/server'
require 'slack-bot-server/service'
require 'slack-bot-server/commands'
