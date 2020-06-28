# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

require_relative 'commands'

run Rails.application

SlackRubyBotServer::App.instance.prepare!
SlackRubyBotServer::Service.start!

run SlackRubyBotServer::Api::Middleware.instance


