### Changelog

#### 0.3.1 (7/10/2016)

* [#22](https://github.com/dblock/slack-ruby-bot-server/issues/22): Subclassing `SlackRubyBotServer::App` creates an `.instance` of child class - [@dblock](https://github.com/dblock).

#### 0.3.0 (7/4/2016)

* Specify the server class via `SlackRubyBotServer.configure`, default is `SlackRubyBotServer::Server` - [@dblock](https://github.com/dblock).
* Added service management lifecycle callbacks when a new team is registered, deactivated, etc - [@dblock](https://github.com/dblock).

#### 0.2.0 (6/21/2016)

* Relaxed dependency versions, notably enabling grape 0.16.2 and Swagger 0.21.0 that uses Swagger 2.0 spec - [@dblock](https://github.com/dblock).
* [#21](https://github.com/dblock/slack-ruby-bot-server/issues/21): Fix: pass additional options through into `SlackRubyBot::Server` - [@dblock](https://github.com/dblock).

#### 0.1.1 (6/4/2016)

* [#14](https://github.com/dblock/slack-ruby-bot-server/pull/14): Moved config/initializers into the library - [@tmsrjs](https://github.com/tmsrjs).

#### 0.1.0 (6/1/2016)

* Initial public release - [@dblock](https://github.com/dblock).
* 2016/6/1: Renamed slack-bot-server to slack-ruby-bot-server - [@dblock](https://github.com/dblock).
* 2016/5/30: [#11](https://github.com/dblock/slack-ruby-bot-server/pull/11) Turn project into gem - [@tmsrjs](https://github.com/tmsrjs).
* 2016/5/5: Use `celluloid-io` instead of `faye-websocket`, upgrade to slack-ruby-bot 0.8.0 - [@dblock](https://github.com/dblock).
* 2016/4/18: Fixed `SlackRubyBotServer#reset` - [@dblock](https://github.com/dblock).
* 2016/4/18: Use Grape 0.15.x - [@dblock](https://github.com/dblock).
* 2016/4/18: Removed OOB GC - [@dblock](https://github.com/dblock).
* 2016/2/11: Use Unicorn instead of Puma - [@dblock](https://github.com/dblock).
* 2016/2/11: Fix: wait for EventMachine reactor to start - [@dblock](https://github.com/dblock).
* 2016/2/11: Use an OOB GC - [@dblock](https://github.com/dblock).
* 2016/2/9: Defer start, much faster - [@dblock](https://github.com/dblock).
* 2016/1/10: Backported changes from slack-metabot and slack-shellbot - [@dblock](https://github.com/dblock).
