require 'celluloid/current'
require 'kaminari/grape'
require 'mongoid-scroll'
require 'grape-swagger'
require 'slack-ruby-bot'

Dir[File.expand_path('../config/initializers', __dir__) + '/**/*.rb'].each do |file|
  require file
end

require 'slack-ruby-bot-server/version'
require 'slack-ruby-bot-server/info'
require 'slack-ruby-bot-server/models'
require 'slack-ruby-bot-server/api'
require 'slack-ruby-bot-server/app'
require 'slack-ruby-bot-server/server'
require 'slack-ruby-bot-server/service'
