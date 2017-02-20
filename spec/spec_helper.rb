ENV['RACK_ENV'] = 'test'

require 'hyperclient'
require 'webmock/rspec'
require 'slack-ruby-bot-server/rspec'
require 'support/capybara'
require 'support/database_cleaner'
require 'support/rspec'
require 'support/vcr'
require 'support/api/*.rb'

SlackRubyBotServer::Service.logger.level = Logger::WARN

if SlackRubyBotServer::Config.pg?
  require 'spec/support/database_adapters/pg/*.rb'
elsif SlackRubyBotServer::Config.mongoid?
  require 'spec/support/database_adapters/mongoid/*.rb'
end
