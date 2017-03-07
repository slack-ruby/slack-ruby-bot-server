$LOAD_PATH.unshift File.expand_path('..', __dir__)

ENV['RACK_ENV'] = 'test'

require 'mongoid'
require 'database_cleaner'
require 'slack-ruby-bot-server/rspec'

Mongoid.load!(File.expand_path('../config/mongoid.yml', __dir__), ENV['RACK_ENV'])

RSpec.configure do |config|
  config.before :suite do
    Mongo::Logger.logger.level = Logger::INFO

    Mongoid::Tasks::Database.create_indexes
  end

  config.after :suite do
    Mongoid.purge!
  end

  config.around :each do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
