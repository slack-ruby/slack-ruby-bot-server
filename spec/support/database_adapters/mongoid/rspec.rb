RSpec.configure do |config|
  config.before :suite do
    Mongoid::Tasks::Database.create_indexes
  end

  config.after :suite do
    Mongoid.purge!
  end
end
