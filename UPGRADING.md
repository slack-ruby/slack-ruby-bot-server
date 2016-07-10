Upgrading Slack-Ruby-Bot-Server
===============================

### Upgrading to >= 0.3.1

#### Remove Monkey-Patching of SlackRubyBotServer::App

You no longer need to monkey-patch the app class. You can subclass it and invoke additional `prepare!` methods.

```ruby
class MyApp < SlackRubyBotServer::App
  def prepare!
    super
    deactivate_sleepy_teams!
  end

  private

  def deactivate_sleepy_teams!
    Team.active.each do |team|
      next unless team.sleepy?
      team.deactivate!
    end
  end
end
```

Make sure to create an `.instance` of the child class.

```ruby
MyApp.instance.prepare!
```

See [#22](https://github.com/dblock/slack-ruby-bot-server/issues/22) for additional information.

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
