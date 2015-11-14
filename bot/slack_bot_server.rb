require 'service'
require 'client'

Mongoid.load! File.expand_path('../../config/mongoid.yml', __FILE__), ENV['RACK_ENV']

def logger
  @logger ||= begin
    $stdout.sync = true
    Logger.new(STDOUT)
  end
end

Thread.new do
  begin
    EM.run do
      SlackRubyBot::Service.start_from_database!
    end
  rescue Exception => e
    logger.error e
    raise e
  end
end
