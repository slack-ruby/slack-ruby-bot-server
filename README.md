Slack Ruby Bot Server
=====================

[![Gem Version](https://badge.fury.io/rb/slack-ruby-bot-server.svg)](https://badge.fury.io/rb/slack-ruby-bot-server)
[![Build Status](https://travis-ci.org/dblock/slack-ruby-bot-server.svg?branch=master)](https://travis-ci.org/dblock/slack-ruby-bot-server)
[![Code Climate](https://codeclimate.com/github/dblock/slack-ruby-bot-server.svg)](https://codeclimate.com/github/dblock/slack-ruby-bot-server)

An opinionated boilerplate and demo for a complete Slack bot service with Slack button integration, in Ruby. If you are not familiar with Slack bots or Slack API concepts, you might want to watch [this video](http://code.dblock.org/2016/03/11/your-first-slack-bot-service-video.html). A good demo of a service built on top of this is [playplay.io](http://playplay.io).

### Try Me

A demo version of this app is running on Heroku at [slack-ruby-bot-server.herokuapp.com](https://slack-ruby-bot-server.herokuapp.com). Use the _Add to Slack_ button. The bot will join your team as _@slackbotserver_.

![](images/slackbutton.gif)

Once a bot is registered, you can invite to a channel with `/invite @slackbotserver` interact with it. DM "hi" to it, or say "@slackbotserver hi".

![](images/slackbotserver.gif)

### What is this?

A [Grape](http://github.com/ruby-grape/grape) API serving a [Slack Ruby Bot](https://github.com/dblock/slack-ruby-bot) to multiple teams. This gem combines a web server, a RESTful API and multiple instances of [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot). It integrates with the [Slack Platform API](https://medium.com/slack-developer-blog/launch-platform-114754258b91#.od3y71dyo).
Your customers can use a Slack button to install the bot.

### Run Your Own

You can use the [sample application](sample_app) to bootstrap your project and start adding slack command handlers on top of this code.

Install [MongoDB](https://www.mongodb.org/downloads), required to store teams.

[Create a New Application](https://api.slack.com/applications/new) on Slack.

![](images/new.png)

Follow the instructions, note the app's client ID and secret, give the bot a default name, etc. The redirect URL should be the location of your app, for testing purposes use `http://localhost:9292`. Edit your `.env` file and add `SLACK_CLIENT_ID=...` and `SLACK_CLIENT_SECRET=...` in it. Run `bundle install` and `foreman start`. Navigate to [localhost:9292](http://localhost:9292). Register using the Slack button.

If you deploy to Heroku set `SLACK_CLIENT_ID` and `SLACK_CLIENT_SECRET` via `heroku config:add SLACK_CLIENT_ID=... SLACK_CLIENT_SECRET=...`.

### Examples Using Slack Ruby Bot Server

* [slack-gamebot](https://github.com/dblock/slack-gamebot), free service at [playplay.io](http://playplay.io)
* [slack-shellbot](https://github.com/dblock/slack-shellbot), free service at [shell.playplay.io](http://shell.playplay.io)
* [api-explorer](https://github.com/dblock/slack-api-explorer), free service at [api-explorer.playplay.io](http://api-explorer.playplay.io)
* [slack-market](https://github.com/dblock/slack-market), free service at [market.playplay.io](http://market.playplay.io)

### Copyright & License

Copyright [Daniel Doubrovkine](http://code.dblock.org), 2015-2016

[MIT License](LICENSE)
