require 'capybara/rspec'

Capybara.configure do |config|
  config.app = SlackRubyBotServer::Api::Middleware.instance
  config.server_port = 9293
  config.server = :webrick
end
