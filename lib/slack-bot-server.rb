require 'celluloid/current'
require 'kaminari/grape'
require 'mongoid-scroll'
require 'grape-swagger'
require 'slack-ruby-bot'

Dir[File.expand_path('../config/initializers', __dir__) + '/**/*.rb'].each do |file|
  require file
end

require 'slack-bot-server/version'
require 'slack-bot-server/info'
require 'slack-bot-server/models'
require 'slack-bot-server/api'
require 'slack-bot-server/app'
require 'slack-bot-server/server'
require 'slack-bot-server/service'
