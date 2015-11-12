require File.expand_path('../config/environment', __FILE__)

EM.run do
  run SlackBotServer::App.instance
end
