Slack Ruby Bot Server
=====================

[![Gem Version](https://badge.fury.io/rb/slack-ruby-bot-server.svg)](https://badge.fury.io/rb/slack-ruby-bot-server)
[![Code Climate](https://codeclimate.com/github/slack-ruby/slack-ruby-bot-server.svg)](https://codeclimate.com/github/slack-ruby/slack-ruby-bot-server)
[![mongodb](https://github.com/slack-ruby/slack-ruby-bot-server/actions/workflows/test-mongodb.yml/badge.svg)](https://github.com/slack-ruby/slack-ruby-bot-server/actions/workflows/test-mongodb.yml)
[![postgresql](https://github.com/slack-ruby/slack-ruby-bot-server/actions/workflows/test-postgresql.yml/badge.svg)](https://github.com/slack-ruby/slack-ruby-bot-server/actions/workflows/test-postgresql.yml)
[![rubocop](https://github.com/slack-ruby/slack-ruby-bot-server/actions/workflows/rubocop.yml/badge.svg)](https://github.com/slack-ruby/slack-ruby-bot-server/actions/workflows/rubocop.yml)

Build a complete Slack bot service with Slack button integration, in Ruby.

## Table of Contents

- [What is this?](#what-is-this)
- [Stable Release](#stable-release)
- [Make Your Own](#make-your-own)
- [Usage](#usage)
  - [Storage](#storage)
    - [MongoDB](#mongodb)
    - [ActiveRecord](#activerecord)
  - [OAuth Version and Scopes](#oauth-version-and-scopes)
  - [Slack App](#slack-app)
  - [API](#api)
    - [App](#app)
    - [Service Manager](#service-manager)
      - [Lifecycle Callbacks](#lifecycle-callbacks)
      - [Service Timers](#service-timers)
      - [Extensions](#extensions)
    - [Service Class](#service-class)
  - [HTML Templates](#html-templates)
  - [Access Tokens](#access-tokens)
- [Sample Bots Using Slack Ruby Bot Server](#sample-bots-using-slack-ruby-bot-server)
  - [Slack Bots with Granular Permissions](#slack-bots-with-granular-permissions)
  - [Legacy Slack Bots](#legacy-slack-bots)
- [Copyright & License](#copyright--license)

## What is this?

A library that contains a web server and a RESTful [Grape](http://github.com/ruby-grape/grape) API serving a Slack bot to multiple teams. Use in conjunction with [slack-ruby-bot-server-events](https://github.com/slack-ruby/slack-ruby-bot-server-events) to build a complete Slack bot service, or [slack-ruby-bot-server-rtm](https://github.com/slack-ruby/slack-ruby-bot-server-rtm) to build a (legacy) Classic RealTime Slack bot. Your customers can use a Slack button to install the bot.

## Stable Release

You're reading the documentation for the **next** release of slack-ruby-bot-server. Please see the documentation for the [last stable release, v1.2.1](https://github.com/slack-ruby/slack-ruby-bot-server/blob/v1.2.1/README.md) unless you're integrating with HEAD. See [UPGRADING](UPGRADING.md) when upgrading from an older version. See [MIGRATING](MIGRATING.md) for help with migrating Legacy Slack Apps to Granular Scopes.

## Make Your Own

This library alone will only register a new bot, but will not include any bot functionality. To make something useful, we recommend you get started from either [slack-ruby-bot-server-events-app-mentions-sample](https://github.com/slack-ruby/slack-ruby-bot-server-events-app-mentions-sample) (handles a single kind of event), or [slack-ruby-bot-server-events-sample](https://github.com/slack-ruby/slack-ruby-bot-server-events-sample) (handles all kinds of events) to bootstrap your project.

## Usage

### Storage

A database is required to store teams.

#### MongoDB

Use MongoDB with [Mongoid](https://github.com/mongodb/mongoid) as ODM. Configure the database connection in `mongoid.yml`. Add the `mongoid` gem in your Gemfile.

```
gem 'mongoid'
gem 'kaminari-mongoid'
gem 'mongoid-scroll'
gem 'slack-ruby-bot-server'
```

#### ActiveRecord

Use ActiveRecord with, for example, PostgreSQL via [pg](https://github.com/ged/ruby-pg). Add the `activerecord`, `pg`, `otr-activerecord` and `cursor_pagination` gems to your Gemfile.

```
gem 'pg'
gem 'activerecord', require: 'active_record'
gem 'slack-ruby-bot-server'
gem 'otr-activerecord'
gem 'cursor_pagination'
```

Configure the database connection in `config/postgresql.yml`. 

```yaml
default: &default
  adapter: postgresql
  pool: 10
  timeout: 5000
  encoding: unicode

development:
  <<: *default
  database: bot_development

test:
  <<: *default
  database: bot_test

production:
  <<: *default
  database: bot
```

Establish a connection in your startup code.

```ruby
ActiveRecord::Base.establish_connection(
  YAML.safe_load(
    ERB.new(
      File.read('config/postgresql.yml')
    ).result, [], [], true
  )[ENV['RACK_ENV']]
)
```

### OAuth Version and Scopes

Configure your app's [OAuth version](https://api.slack.com/authentication/oauth-v2) and [scopes](https://api.slack.com/legacy/oauth-scopes) as needed by your application.

```ruby
SlackRubyBotServer.configure do |config|
  config.oauth_version = :v2
  config.oauth_scope = ['channels:read', 'chat:write']
end
```

The "Add to Slack" button uses the standard OAuth code grant flow as described in the [Slack docs](https://api.slack.com/docs/oauth#flow). Once clicked, the user is taken through the authorization process at Slack's site. Upon successful completion, a callback containing a temporary code is sent to the redirect URL you specified. The endpoint at that URL contains code that persists the bot token each time a Slack client is instantiated for the specific team.

### Slack App

Create a new Slack App [here](https://api.slack.com/applications/new).

![](images/create-app.png)

Follow Slack's instructions, note the app client ID and secret, give the bot a default name, etc.

Within your application, edit your `.env` file and add `SLACK_CLIENT_ID=...` and `SLACK_CLIENT_SECRET=...` in it.

Run `bundle install` and `foreman start` to boot the app.

```
$ foreman start
07:44:47 web.1  | started with pid 59258
07:44:50 web.1  | * Listening on tcp://0.0.0.0:5000
```

Set the redirect URL in "OAuth & Permissions" be the location of your app. Since you cannot receive notifications on localhost from Slack use a public tunneling service such as [ngrok](https://ngrok.com/) to expose local port 9292 for testing.

```
$ ngrok http 5000
Forwarding https://ddfd97f80615.ngrok.io -> http://localhost:5000
```

Navigate to either [localhost:9292](http://localhost:9292) or the ngrok URL above. You should see an "Add to Slack" button. Use it to install the app into your own Slack team.

### API

This library implements an app, [SlackRubyBotServer::App](lib/slack-ruby-bot-server/app.rb) and a service manager, [SlackRubyBotServer::Service](lib/slack-ruby-bot-server/service.rb). It also provides [default HTML templates and JS scripts](public) for Slack integration.

#### App

The app instance checks for a working database connection, ensures indexes, performs migrations, sets up bot aliases and log levels. You can introduce custom behavior into the app lifecycle by subclassing `SlackRubyBotServer::App` and creating an instance of the child class in `config.ru`.

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

```ruby
MyApp.instance.prepare!
```

#### Service Manager

##### Lifecycle Callbacks

You can introduce custom behavior into the service lifecycle via callbacks. This can be useful when new team has been registered via the API or a team has been deactivated from Slack.

```ruby
instance = SlackRubyBotServer::Service.instance

instance.on :started, :stopped do |team|
  # team has been started or stopped
end

instance.on :created do |team, error, options|
  # a new team has been registered
end

instance.on :deactivated do |team, error, options|
  # an existing team has been deactivated in Slack
end

instance.on :error do |team, error, options|
  # an error has occurred
end
```

The following callbacks are supported. All callbacks receive a `team`, except `error`, which receives a `StandardError` object.

| callback       |  description                                                     |
|:--------------:|:-----------------------------------------------------------------|
| error          | an error has occurred                                            |
| creating       | a new team is being registered                                   |
| created        | a new team has been registered                                   |
| booting        | the service is starting and is connecting a team to Slack        |
| booted         | the service is starting and has connected a team to Slack        |
| stopping       | the service is about to disconnect a team from Slack             |
| stopped        | the service has disconnected a team from Slack                   |
| starting       | the service is (re)connecting a team to Slack                    |
| started        | the service has (re)connected a team to Slack                    |
| deactivating   | a team is being deactivated                                      |
| deactivated    | a team has been deactivated                                      |

The [Add to Slack button](https://api.slack.com/docs/slack-button) also allows for an optional `state` parameter that will be returned on completion of the request. The `creating` and `created` callbacks include an options hash where this value can be accessed (to check for forgery attacks for instance).
```ruby
auth = OpenSSL::HMAC.hexdigest("SHA256", "key", "data")
```
```html
<a href="<%= SlackRubyBotServer::Config.oauth_authorize_url %>?scope=<%= SlackRubyBotServer::Config.oauth_scope_s %>&client_id=<%= ENV['SLACK_CLIENT_ID'] %>&state=#{auth)"> ... </a>
```
```ruby
instance = SlackRubyBotServer::Service.instance
instance.on :creating do |team, error, options|
  raise "Unauthorized response" unless options[:state] == auth
end
```

##### Service Timers

You can introduce custom behavior into the service lifecycle on a timer. For example, check whether a team's trial has expired, or periodically cleanup data.

Note that unlike callbacks, timers are global for the entire service.

```ruby
instance = SlackRubyBotServer::Service.instance

instance.every :hour do
  Team.each do |team|
    begin
      # do something with every team once an hour
    rescue StandardError
    end
  end
end

instance.every :minute do
  # called every minute
end

instance.every :second do
  # called every second
end

instance.every 30 do
  # called every 30 seconds
end
```

##### Extensions

A number of extensions use service manager callbacks and service timers to implement useful functionality.

* [slack-ruby-bot-server-events](https://github.com/slack-ruby/slack-ruby-bot-server-events): Easily handle Slack slash commands, interactive buttons and events.
* [slack-ruby-bot-server-mailchimp](https://github.com/slack-ruby/slack-ruby-bot-server-mailchimp): Subscribes new bot users to a Mailchimp mailing list.
* [slack-ruby-bot-server-stripe](https://github.com/slack-ruby/slack-ruby-bot-server-stripe): Enables paid bots with trial periods and commerce through Stripe.
* [slack-ruby-bot-server-rtm](https://github.com/slack-ruby/slack-ruby-bot-server-rtm): Create RTM Slack bots.

#### Service Class

You can override the service class to handle additional methods.

```ruby
class MyService < SlackRubyBotServer::Service
  def url
    'https://www.example.com'
  end
end

SlackRubyBotServer.configure do |config|
  config.service_class = MyService
end

SlackRubyBotServer::Service.instance # MyService
SlackRubyBotServer::Service.instance.url # https://www.example.com
```

### HTML Templates

This library provides a [default HTML template and JS scripts](public) that implement the "Add to Slack" button workflow. Customize your pages by adding a `public` directory in your application and starting with a [index.html.erb](public/index.html.erb) template. The application's `views` and `public` folders are [loaded by default](lib/slack-ruby-bot-server/api/middleware.rb#L32).

You can add to or override template paths as follows.

```ruby
SlackRubyBotServer.configure do |config|
  config.view_paths << File.expand_path(File.join(__dir__, 'public'))
end
```

### Access Tokens

By default the implementation of [Team](lib/slack-ruby-bot-server/models/team) stores the value of the token with all the requested OAuth scopes in both `token` and `activated_user_access_token` (for backwards compatibility), along with `oauth_version` and `oauth_scope`. If a legacy Slack bot integration `bot_access_token` is present, it is stored as `token`, and `activated_user_access_token` is the token that has all the requested OAuth scopes.

## Sample Bots Using Slack Ruby Bot Server

### Slack Bots with Granular Permissions

* [slack-ruby-bot-server-events-sample](https://github.com/slack-ruby/slack-ruby-bot-server-events-sample), a generic sample
* [slack-rails-bot-starter](https://github.com/CrazyOptimist/slack-rails-bot-starter), an all-in-one Rails starter kit

### Legacy Slack Bots

* [slack-ruby-bot-server-sample](https://github.com/slack-ruby/slack-ruby-bot-server-sample), a generic sample
* [slack-sup](https://github.com/dblock/slack-sup), see [sup.playplay.io](https://sup.playplay.io)
* [slack-gamebot](https://github.com/dblock/slack-gamebot), see [www.playplay.io](https://www.playplay.io)
* [slack-market](https://github.com/dblock/slack-market), see [market.playplay.io](https://market.playplay.io)
* [slack-shellbot](https://github.com/slack-ruby/slack-shellbot), see [shell.playplay.io](https://shell.playplay.io)
* [slack-api-explorer](https://github.com/slack-ruby/slack-api-explorer), see [api-explorer.playplay.io](https://shell.playplay.io)
* [slack-strava](https://github.com/dblock/slack-strava), see [slava.playplay.io](https://slava.playplay.io)
* [slack-arena](https://github.com/dblock/slack-arena), see [arena.playplay.io](https://arena.playplay.io)

## Copyright & License

Copyright [Daniel Doubrovkine](http://code.dblock.org) and Contributors, 2015-2020

[MIT License](LICENSE)
