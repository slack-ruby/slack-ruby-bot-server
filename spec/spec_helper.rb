$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'byebug'
require 'fabrication'
require 'faker'
require 'hyperclient'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

require 'slack-ruby-bot/rspec'
require 'slack-bot-server'

Dir[File.join(File.dirname(__FILE__), 'support', '**/*.rb')].each do |file|
  require file
end
