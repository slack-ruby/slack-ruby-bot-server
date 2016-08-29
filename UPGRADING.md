Upgrading Slack-Ruby-Bot-Server
===============================

### Upgrading to >= 0.4.0

#### Add giphy to your Gemfile for GIF support

The dependency on the `giphy` gem was dropped in slack-ruby-bot 0.9.0 and GIFs don't appear by default. If you want GIF support, add `gem 'giphy'` to your **Gemfile**.

See [slack-ruby-bot#89](https://github.com/slack-ruby/slack-ruby-bot/pull/89) for more information.

#### Changes in Callbacks

The `SlackRubyBotServer::Service` class used to track services in a `Hash`. This is no longer the case. Callbacks no longer receive a server object for the team, but the latter is assigned as `team.server`.

```ruby
instance = SlackRubyBotServer::Service.instance

instance.on :started do |team, error|
  # a new team has been registered
  # team.server is available
end
```

The `reset` and `resetting` callbacks have also been removed.

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

See [#22](https://github.com/slack-ruby/slack-ruby-bot-server/issues/22) for additional information.

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

See [#18](https://github.com/slack-ruby/slack-ruby-bot-server/issues/18) for more information.
