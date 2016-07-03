Upgrading Slack-Ruby-Bot-Server
===============================

### Upgrading to >= 0.3.0

#### Remove Monkey-Patching of SlackRubyBotServer::Server

In the past adding events required monkey-patching of the server class. You can now override the server class to handle additional events, and configure the service to use yours.

```ruby
class MyServerClass < SlackRubyBotServer::Server
  on :hello do |client, data|
    # connected to Slack
  end

  on :channel_joined do |client, data|
    # the bot joined a channel in data.channel['id']
  end
end

SlackRubyBotServer.configure do |config|
  config.server_class = MyServerClass
end
```

See [#18](https://github.com/dblock/slack-ruby-bot-server/issues/18) for more information.
