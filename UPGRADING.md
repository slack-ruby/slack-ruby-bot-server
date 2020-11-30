Upgrading Slack-Ruby-Bot-Server
===============================

### Upgrading to >= 1.2.0

#### New Team Fields

The following fields have been added to `Team`.

* `oauth_scope`: Slack OAuth scope
* `oauth_version`: Slack OAuth version used

No action is required for Mongoid.

If you're using ActiveRecord, create a migration to add these fields.

```ruby
class AddOauthFields < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :oauth_scope, :string
    add_column :teams, :oauth_version, :string, default: 'v1', null: false
  end
end
```

See [MIGRATING](MIGRATING.md) for help with migrating Legacy Slack Apps to Granular Scopes.

### Upgrading to >= 1.1.0

#### Extracted RealTime (Legacy) Support

New slack apps may no longer access RTM. Classic Slack apps can no longer be submitted to the app directory as of December 4th, 2020. In preparation for these changes slack-ruby-bot-server no longer includes RTM components by default. These have been extracted to a new gem [slack-ruby-bot-server-rtm](https://github.com/slack-ruby/slack-ruby-bot-server-rtm).

To upgrade an existing classic Slack app that uses slack-ruby-bot-server do the following.

1. Add `slack-ruby-bot-server-rtm` as an additional dependency.
2. Replace any reference to `SlackRubyBotServer::Server` to `SlackRubyBotServer::RealTime::Server`.
3. Replace any `require 'slack-ruby-bot-server/rspec'` with `require 'slack-ruby-bot-server-rtm/rspec'`.
4. Use Slack OAuth 1.0 and configure scopes.
   ```ruby
   SlackRubyBotServer.configure do |config|
     config.oauth_version = :v1
     config.oauth_scope = ['bot']
   end
   ```

Existing RTM Slack bots will continue working and be listed in the Slack App Directory. On December 4th, 2020 Slack will no longer accept resubmissions from apps that are not using granular permissions. On November 18, 2021 Slack will start delisting apps that have not migrated to use granular permissions. Use [slack-ruby-bot-server-events](https://github.com/slack-ruby/slack-ruby-bot-server-events) to create a Slack bot with granular permissions. See [migration](https://api.slack.com/authentication/migration) for more details.

### Upgrading to >= 0.11.0

#### Removed Legacy Migrations

Several legacy migrations have been removed, including the code to automatically create a team from a legacy `SLACK_API_TOKEN`, setting `Team#active`, `name` and `team_id`.

See [#101](https://github.com/slack-ruby/slack-ruby-bot-server/pull/101) for more information.

#### Unicorn Dependency

The dependency on `unicorn` has been removed from gemspec. Use `unicorn` or `puma` or another application server as you see fit by explicitly adding a dependency in your Gemfile.

See [#98](https://github.com/slack-ruby/slack-ruby-bot-server/pull/98) for more information.

### Upgrading to >= 0.10.0

#### New Team Fields

The following fields have been added to `Team`.

* `bot_user_id`: the bot `user_id` during installation
* `activated_user_id`: the installing Slack user `user_id`
* `activated_user_access_token`: the installing Slack user `access_token`

No action is required for Mongoid.

If you're using ActiveRecord, create a migration similar to [sample_apps/sample_app_activerecord/db/migrate/20190323181453_add_activated_fields.rb](sample_apps/sample_app_activerecord/db/migrate/20190323181453_add_activated_fields.rb) to add these fields.

```ruby
class AddActivatedFields < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :bot_user_id, :string
    add_column :teams, :activated_user_id, :string
    add_column :teams, :activated_user_access_token, :string
  end
end
```

See [#96](https://github.com/slack-ruby/slack-ruby-bot-server/pull/96) for more information.

### Upgrading to >= 0.9.0

#### Removed Ping Worker

The ping worker that was added in 0.7.0 has been removed in favor of a lower level implementation in slack-ruby-client. Remove any references to `ping` options.

See [slack-ruby-client#226](https://github.com/slack-ruby/slack-ruby-client/pull/226) and [#93](https://github.com/slack-ruby/slack-ruby-bot-server/pull/93) for more information.

### Upgrading to >= 0.8.0

#### Different Asynchronous I/O Library

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
