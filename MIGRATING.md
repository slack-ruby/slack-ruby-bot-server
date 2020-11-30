### Introduction

Slack recently [introduced granular permissions](https://medium.com/slack-developer-blog/more-precision-less-restrictions-a3550006f9c3) and is now requiring all new apps to use them. The old apps are called _classic_ apps. Slack also provided a [migration guide](https://api.slack.com/authentication/migration).

> As of December 4th, 2020 Slack no longer accept resubmissions from apps that are not using granular permissions. On November 18, 2021 Slack will start delisting apps that have not migrated to use granular permissions. So you better get going with a migration ASAP.

New bots cannot use real-time, and there's no way to automatically migrate existing installations - users must reinstall a newer version of the bot. This migration guide avoids a data migration by allowing you to operate both the old and the new version on top of the same database.

> The migration effectively involves replacing `slack-ruby-bot-server-rtm` with `slack-ruby-bot-server-events`.

### Upgrade to Slack-Ruby-Bot-Server 1.2.0 and Slack-Ruby-Bot-Server-Rtm

Upgrade to the latest version of [slack-ruby-bot-server-rtm](https://github.com/slack-ruby/slack-ruby-bot-server-rtm) , which extracts real-time components. This involves replacing `SlackRubyBotServer::Server` with `SlackRubyBotServer::RealTime::Server`.

Upgrade to [slack-ruby-bot-server](https://github.com/slack-ruby/slack-ruby-bot-server) >= 1.2.0. This version introduces two new `Team` fields, `oauth_version` and `oauth_scope` to store which version of the bot performed the install. This allows slack-ruby-bot-server-rtm to ignore newer bots and only boot RTM for legacy bots.

See [UPGRADING](https://github.com/slack-ruby/slack-ruby-bot-server/blob/master/UPGRADING.md#upgrading-to--120) for more information on ActiveRecord database migrations.

Deploy your bot and make sure everything is working without any changes.

### Create a New Slack App

In order not to affect existing users, [create a new Slack app](https://api.slack.com/apps) with new granular permissions and scopes. For example, to send messages to Slack you will need `chat:write`. To read messages in public channels, `channels:history`. To receive bot mentions you'll need `app_mentions:read` and to receive DMs, `im:history`.

### Respond to Slack Events

#### App Mentions

A typical bot may want to respond to mentions, which is made very easy by the new [slack-ruby-bot-server-events-app-mentions](https://github.com/slack-ruby/slack-ruby-bot-server-events-app-mentions) gem. This is similar to the [commands in slack-ruby-bot](https://github.com/slack-ruby/slack-ruby-bot#commands-and-operators), but you'll need to do the work to actually migrate functionality to mentions, and not all variations of commands and operators are currently supported.

```ruby
SlackRubyBotServer.configure do |config|
  config.oauth_version = :v2
  config.oauth_scope = ['app_mentions:read', 'im:history', 'chat:write']
end
```

```ruby
class Ping < SlackRubyBotServer::Events::AppMentions::Mention
  mention 'ping'

  def self.call(data)
    client = Slack::Web::Client.new(token: data.team.token)
    client.chat_postMessage(channel: data.channel, text: 'pong')
  end
end
```

See a [complete sample](https://github.com/slack-ruby/slack-ruby-bot-server-events-app-mentions-sample) for more details.

#### Other Messages

More advanced bots may want to handle all kinds of messages. For example, [slack-shellbot#22](https://github.com/slack-ruby/slack-shellbot/pull/22) configures scopes to receive the kitchen sink of events, then handles them carefully avoiding handling its own messages.

```ruby
SlackRubyBotServer.configure do |config|
  config.oauth_version = :v2
  config.oauth_scope = ['chat:write', 'im:history', 'mpim:history', 'channels:history', 'groups:history']
end
```

```ruby
SlackRubyBotServer::Events.configure do |config|
  config.on :event, 'event_callback', 'message' do |event|
    # SlackShellbot::Commands::Base.logger.info event

    next true if event['event']['subtype'] # updates, etc.
    next true if event['authorizations'][0]['user_id'] == event['event']['user'] # self

    team = Team.where(team_id: event['team_id']).first
    next true unless team

    data = Slack::Messages::Message.new(event['event'])

    # handles event data here

    true
  end
end
```

### Deploy

Create a new app deployment, use the same database as your production bot. The new bot needs a configuration with the `SLACK_CLIENT_ID`, `SLACK_CLIENT_SECRET` and `SLACK_SIGNING_SECRET` from the new app with granular permissions. Use the same database instance as the old RTM bot.

Now there are two versions of the app running on top of the same database: one is the legacy one, and the other is the granular scopes app. The old app will ignore new bot installations that use granular permissions. The new app should ignore any old bot installations. Thus both apps should work.

### Switch DNS

Switch DNS, new bot registrations can use the new granular scopes app. Make sure in Slack the event URLs are configured properly to point to this DNS.

### Slow Migration for Existing Teams

Existing teams can uninstall the old bot and re-install the new one. The old real-time implementation will stop working once the token has been switched, but the data will remain intact and the team will get reactivated using the new bot with granular permissions.

### Long Version

See [this blog post](http://localhost:4000/2020/11/30/migrating-classic-slack-ruby-bots-to-granular-permissions.html) for a longer, opinionated version of this migration guide.
