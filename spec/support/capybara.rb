require 'capybara/rspec'
Capybara.configure do |config|
  config.app = Api::Middleware.instance
  config.server_port = 9293
end
