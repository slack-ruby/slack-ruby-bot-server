ENV['RACK_ENV'] = 'test'
ENV['DATABASE_ADAPTER'] ||= 'mongoid'

require 'logger'

Bundler.require

require 'hyperclient'
require 'webmock/rspec'
require 'rack/test'
require 'slack-ruby-bot-server/rspec'

Dir[File.join(__dir__, 'support', '**/*.rb')].sort.each do |file|
  require file
end

SlackRubyBotServer::Service.logger.level = Logger::WARN

Dir[File.join(__dir__, 'database_adapters', SlackRubyBotServer::Config.database_adapter.to_s, '**/*.rb')].sort.each do |file|
  require file
end
