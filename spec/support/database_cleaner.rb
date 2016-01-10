require 'database_cleaner'

RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with :truncation
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
