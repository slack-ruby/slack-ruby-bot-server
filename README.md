Slack Bot Server
================

[![Build Status](https://travis-ci.org/dblock/slack-bot-server.svg?branch=master)](https://travis-ci.org/dblock/slack-bot-server)
[![Dependency Status](https://gemnasium.com/dblock/slack-bot-server.svg)](https://gemnasium.com/dblock/slack-bot-server)
[![Code Climate](https://codeclimate.com/github/dblock/slack-bot-server.svg)](https://codeclimate.com/github/dblock/slack-bot-server)

An opinionated boilerplate and demo for a complete Slack bot service with Slack button integration, in Ruby.

### Try Me

A demo version of this app is running on Heroku at [slack-bot-server.herokuapp.com](https://slack-bot-server.herokuapp.com). Use the _Add to Slack_ button. The bot will join your team as _@slackbotserver_.

![](images/slackbutton.gif)

Once a bot is registered, you can invite to a channel with `/invite @slackbotserver` interact with it. DM "hi" to it, or say "@slackbotserver hi".

![](images/slackbotserver.gif)

### What is this?

A [Grape](http://github.com/ruby-grape/grape) API serving a [Slack Ruby Bot](https://github.com/dblock/slack-ruby-bot) to multiple teams. This is a boilerplate that combines a web server, a RESTful API and multiple instances of [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot). It integrates with the [Slack Platform API](https://medium.com/slack-developer-blog/launch-platform-114754258b91#.od3y71dyo).

### How do I use this?

Fork this project and roll out a Slack bot service to multiple teams without needing to create separate application instances. This boilerplate is a means to get you started, but you should also be able to take updates from upstream if you want. Your customers can use a Slack button to install your bot. You can start adding slack command handlers on top of this code.

### Run Your Own

Install [MongoDB](https://www.mongodb.org/downloads), required to store teams.

[Create a New Application](https://api.slack.com/applications/new) on Slack.

![](images/new.png)

Follow the instructions, note the app's client ID and secret, give the bot a default name, etc. The redirect URL should be the location of your app, for testing purposes use `http://localhost:9292`. For a local deployment create a `.env` file and add `SLACK_CLIENT_ID=...` and `SLACK_CLIENT_SECRET=...` in it. Run `bundle install` and `foreman start`. Navigate to [localhost:9292](http://localhost:9292). Register using the Slack button.

If you deploy to Heroku set _SLACK_CLIENT_ID_ and _SLACK_CLIENT_SECRET_ via `heroku config:add SLACK_CLIENT_ID=... SLACK_CLIENT_SECRET=...`.

### Examples Using Slack Bot Server

* [slack-gamebot](https://github.com/dblock/slack-gamebot), free service at [playplay.io](http://playplay.io)
* [slack-shellbot](https://github.com/dblock/slack-shellbot), free service at [shlack.dblock.org](http://shlack.dblock.org)
* [slack-metabot](https://github.com/dblock/slack-metabot), free service at [slack-metabot.dblock.org](http://slack-metabot.dblock.org)

### Copyright & License

Copyright [Daniel Doubrovkine](http://code.dblock.org), 2015-2016

[MIT License](LICENSE)
