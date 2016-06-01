ENV['RACK_ENV'] = 'test'

require 'hyperclient'
require 'webmock/rspec'

require 'slack-ruby-bot-server/rspec'

SlackRubyBotServer::Service.logger.level = Logger::WARN

Mongo::Logger.logger.level = Logger::INFO
Mongoid.load!(File.expand_path('../sample_app/config/mongoid.yml', __dir__), ENV['RACK_ENV'])

Dir[File.join(__dir__, 'support', '**/*.rb')].each do |file|
  require file
end
