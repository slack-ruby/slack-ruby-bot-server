require 'capybara/rspec'
Capybara.configure do |config|
  config.app = SlackBotServer::Api::Middleware.instance
  config.server_port = 9293
end
