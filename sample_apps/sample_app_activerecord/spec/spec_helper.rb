$LOAD_PATH.unshift File.expand_path('..', __dir__)

ENV['RACK_ENV'] = 'test'

require 'slack-ruby-bot-server/rspec'

RSpec.configure do |config|
  config.around :each do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
