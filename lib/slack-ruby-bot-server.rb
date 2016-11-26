require 'celluloid/current'

if ENV['MONGO_URL'] || ENV['MONGOHQ_URI'] || ENV['MONGODB_URI'] || ENV['MONGOLAB_URI']
  require 'kaminari/grape'
  require 'mongoid-scroll'
end

require 'grape-swagger'
require 'slack-ruby-bot'

require 'slack-ruby-bot-server/ext'
require 'slack-ruby-bot-server/version'
require 'slack-ruby-bot-server/info'

require 'slack-ruby-bot-server/models/team_mongo.rb' if ENV['MONGO_URL'] || ENV['MONGOHQ_URI'] || ENV['MONGODB_URI'] || ENV['MONGOLAB_URI']
require 'slack-ruby-bot-server/models/team_postgres.rb' if ENV['SLACK_BOT_POSTGRES_URL']

require 'slack-ruby-bot-server/api'
require 'slack-ruby-bot-server/app'
require 'slack-ruby-bot-server/server'
require 'slack-ruby-bot-server/config'
require 'slack-ruby-bot-server/service'
