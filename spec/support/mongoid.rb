RSpec.configure do |config|
  config.before :suite do
    Mongoid::Tasks::Database.create_indexes
  end
end
