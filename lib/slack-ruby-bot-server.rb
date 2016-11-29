require 'celluloid/current'

require 'grape-swagger'
require 'slack-ruby-bot'
require 'slack-ruby-bot-server/server'
require 'slack-ruby-bot-server/config'

require 'slack-ruby-bot-server/ext'
require 'slack-ruby-bot-server/version'
require 'slack-ruby-bot-server/info'

if SlackRubyBotServer::Config.mongo?
  require 'slack-ruby-bot-server/models/team/mongo.rb'
  require 'kaminari/grape'
  require 'mongoid-scroll'
end

require 'slack-ruby-bot-server/models/team/postgres.rb' if SlackRubyBotServer::Config.postgresql?

require 'slack-ruby-bot-server/api'
require 'slack-ruby-bot-server/app'
require 'slack-ruby-bot-server/service'
