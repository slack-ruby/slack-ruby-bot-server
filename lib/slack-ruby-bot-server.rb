require 'celluloid/current'

require 'grape-swagger'
require 'slack-ruby-bot'
require 'slack-ruby-bot-server/server'
require 'slack-ruby-bot-server/config'

require 'slack-ruby-bot-server/ext'
require 'slack-ruby-bot-server/version'
require 'slack-ruby-bot-server/info'

require "config/database_adapters/#{SlackRubyBotServer::Config.database_adapter.to_s}"

require 'slack-ruby-bot-server/api'
require 'slack-ruby-bot-server/app'
require 'slack-ruby-bot-server/service'
