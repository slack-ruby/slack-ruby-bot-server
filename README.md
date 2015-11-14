Slack Bot Server
================

[![Build Status](https://travis-ci.org/dblock/slack-bot-server.svg?branch=master)](https://travis-ci.org/dblock/slack-bot-server)
[![Dependency Status](https://gemnasium.com/dblock/slack-bot-server.svg)](https://gemnasium.com/dblock/slack-bot-server)
[![Code Climate](https://codeclimate.com/github/dblock/slack-bot-server.svg)](https://codeclimate.com/github/dblock/slack-bot-server)

### What is this?

A [Grape](http://github.com/ruby-grape/grape) API serving a [Slack Ruby Bot](https://github.com/dblock/slack-ruby-bot) to multiple teams. This is a boilerplate sample that combines a web server, a RESTful API and multiple instances of [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot). Fork this project and roll out a Slack bot service to multiple teams without needing to create separate application instances.

![](images/demo.gif)

### See It

Create a new bot integration. This is something done in Slack, under [integrations](https://artsy.slack.com/services). Create a [new bot](https://artsy.slack.com/services/new/bot), and note its API token.

A demo version is running on Heroku. Register your team at [slack-bot-server.herokuapp.com](https://slack-bot-server.herokuapp.com). The bot will join your team and the #general channel. Say "hi" to it in a direct message or "@name hi" the bot in #general.

### Run Your Own

Requires [MongoDB](https://www.mongodb.org/downloads) to store teams.

Run `bundle install` and `rackup`. Navigate to [localhost:9292](http://localhost:9292).

### Copyright & License

Copyright [Daniel Doubrovkine](http://code.dblock.org), 2015

[MIT License](LICENSE)
