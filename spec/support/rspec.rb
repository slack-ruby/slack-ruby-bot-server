RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
  config.raise_errors_for_deprecations!

  config.after do
    SlackRubyBotServer.config.reset!
  end
end
