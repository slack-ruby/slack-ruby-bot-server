RSpec.configure do |config|
  config.before :suite do
    Mongoid.logger.level = Logger::INFO
    Mongo::Logger.logger.level = Logger::INFO

    Mongoid::Tasks::Database.create_indexes
  end
end
