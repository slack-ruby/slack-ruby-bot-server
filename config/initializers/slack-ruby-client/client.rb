Slack::RealTime.configure do |config|
  config.concurrency = Slack::RealTime::Concurrency::Faye
end
