module SlackRubyBot
  class Client
    # keep track of the team that the client is connected to
    attr_accessor :owner
  end
end

Slack.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::WARN
end

SlackRubyBot::Client.logger.level = Logger::WARN

Slack::RealTime::Client.configure do |config|
  config.store_class = Slack::RealTime::Stores::Starter
end
