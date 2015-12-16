Slack Bot Server
================

[![Build Status](https://travis-ci.org/dblock/slack-bot-server.svg?branch=master)](https://travis-ci.org/dblock/slack-bot-server)
[![Dependency Status](https://gemnasium.com/dblock/slack-bot-server.svg)](https://gemnasium.com/dblock/slack-bot-server)
[![Code Climate](https://codeclimate.com/github/dblock/slack-bot-server.svg)](https://codeclimate.com/github/dblock/slack-bot-server)

### What is this?

A [Grape](http://github.com/ruby-grape/grape) API serving a [Slack Ruby Bot](https://github.com/dblock/slack-ruby-bot) to multiple teams. This is a boilerplate sample that combines a web server, a RESTful API and multiple instances of [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot). It integrates with the [Slack Platform API](https://medium.com/slack-developer-blog/launch-platform-114754258b91#.od3y71dyo). Fork this project and roll out a Slack bot service to multiple teams without needing to create separate application instances. Your customers can use a Slack button to install your bot.

![](images/slackbutton.gif)

Once a bot is registered, you can interact with it on your #general channel or invite it to another one.

![](images/slackbotserver.gif)

### See It

A demo version is running on Heroku. Register your team at [slack-bot-server.herokuapp.com](https://slack-bot-server.herokuapp.com). Use the _Add to Slack_ button. The bot will join your team as _@slackbotserver_ and the #general channel. Say "hi" to it in a direct message or "@slackbotserver hi" the bot in #general.

### Run Your Own

Install [MongoDB](https://www.mongodb.org/downloads), required to store teams.

[Create a New Application](https://api.slack.com/applications/new) on Slack.

![](images/new.png)

Follow the instructions, note the app's client ID and secret, give the bot a default name, etc. The redirect URL should be the location of your app, for testing purposes use `http://localhost:9292`. If you deploy to Heroku set _SLACK_CLIENT_ID_ and _SLACK_CLIENT_SECRET_.

Run `bundle install` and `foreman start`. Navigate to [localhost:9292](http://localhost:9292). Register using the Slack button.

### Copyright & License

Copyright [Daniel Doubrovkine](http://code.dblock.org), 2015

[MIT License](LICENSE)
