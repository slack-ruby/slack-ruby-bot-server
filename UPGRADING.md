Upgrading Slack-Ruby-Bot-Server
===============================

### Upgrading to >= 0.8.3

To avoid name collisions, `Team` has been renamed `SlackRubyBot::Team`, if you modify the class `Team` add `Team = SlackRubyBot::Team` before the code. 

### Upgrading to >= 0.8.0

### Different Asynchronous I/O Library

The library now uses [async-websocket](https://github.com/socketry/async-websocket) instead of [celluloid-io](https://github.com/celluloid/celluloid-io). If your application is built on Celluloid you may need to make changes and use `Async::Reactor.run` and the likes.

See [#75](https://github.com/slack-ruby/slack-ruby-bot-server/pull/75) for more information.

### Upgrading to >= 0.7.0

#### New Ping Worker

Version 0.7.0 will automatically start a ping worker that checks for the bot's online status and forcefully terminate and restart disconnected bots. Set the ping `enabled` option to `false` to disable this behavior.

```ruby
SlackRubyBotServer.configure do |config|
  config.ping = {
    enabled: false
  }
end
```

If you are currently using a custom ping worker as suggested in [slack-ruby-client#208](https://github.com/slack-ruby/slack-ruby-client/issues/208), delete it.

See [#74](https://github.com/slack-ruby/slack-ruby-bot-server/pull/74) for more information.

### Upgrading to >= 0.6.0

#### Mongoid and ActiveRecord support

Version 0.6.0 supports both Mongoid and ActiveRecord. The `mongoid` gem is no longer a dependency, so you must manually add the gems in your Gemfile.

##### Mongoid

```
gem 'mongoid'
gem 'slack-ruby-bot-server'
```

##### ActiveRecord (with PostgreSQL)

```
gem 'pg'
gem 'activerecord', require: 'active_record'
gem 'slack-ruby-bot-server'
```

The order matters, and the driver is required _first_, otherwise you will get a `One of "mongoid" or "activerecord" is required.` error.

See [#48](https://github.com/slack-ruby/slack-ruby-bot-server/pull/48) for more information.

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
    SlackRubyBotServer::Team.active.each do |team|
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
