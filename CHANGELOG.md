### Changelog

#### 0.7.0 (8/22/2018)

* [#60](https://github.com/slack-ruby/slack-ruby-bot-server/pull/60): Log caught Standard::Error backtrace at debug-level - [@alexagranov](https://github.com/alexagranov).
* [#65](https://github.com/slack-ruby/slack-ruby-bot-server/pull/65): Updated Capybara and selenium-webdriver - [@dblock](https://github.com/dblock).
* [#67](https://github.com/slack-ruby/slack-ruby-bot-server/pull/67): Only load the OTR::ActiveRecord::ConnectionManagement middleware when the OTR module is included. This module isn't needed when using Rails - [@darbyfrey](https://github.com/darbyfrey).
* [#74](https://github.com/slack-ruby/slack-ruby-bot-server/pull/74): Added ping worker, will restart offline bots - [@dblock](https://github.com/dblock).

#### 0.6.1 (3/29/2017)

* [#54](https://github.com/slack-ruby/slack-ruby-bot-server/pull/54): Removing one more Mongoid dependency when rescuing from _invoke - [@alexagranov](https://github.com/alexagranov).
* [#53](https://github.com/slack-ruby/slack-ruby-bot-server/pull/53): No need for `otr-activerecord` if using activerecord under Rails - [@alexagranov](https://github.com/alexagranov).

#### 0.6.0 (3/12/2017)

* [#38](https://github.com/slack-ruby/slack-ruby-bot-server/issues/7): Added ActiveRecord support - [@zachfeldman](https://github.com/zachfeldman), [@spencerldixon](https://github.com/spencerldixon), [@dblock](https://github.com/dblock).
* [#45](https://github.com/slack-ruby/slack-ruby-bot-server/pull/45): Updated grape-roar to 0.4.0 - [@swalberg](https://github.com/swalberg).
* [#49](https://github.com/slack-ruby/slack-ruby-bot-server/pull/49): Run tests in the sample apps part of CI - [@dblock](https://github.com/dblock).

#### 0.5.0 (2/9/2017)

* [#43](https://github.com/slack-ruby/slack-ruby-bot-server/pull/43): Fix: `cannot load kaminari/grape` - [@dblock](https://github.com/dblock).
* [#43](https://github.com/slack-ruby/slack-ruby-bot-server/pull/43): Fix: `undefined method '[]' for nil:NilClass` in APIs - [@dblock](https://github.com/dblock).
* [#28](https://github.com/slack-ruby/slack-ruby-bot-server/pull/28): Use slack-ruby-danger gem - [@dblock](https://github.com/dblock).
* [#31](https://github.com/slack-ruby/slack-ruby-bot-server/pull/31): Adds MONGODB_URI as environment variable for MongoDB - [@corprew](https://github.com/corprew).

#### 0.4.0 (8/29/2016)

* [#25](https://github.com/slack-ruby/slack-ruby-bot-server/pull/25): Added [danger](http://danger.systems), PR linting - [@dblock](https://github.com/dblock).
* The `reset` and `resetting` callbacks have been removed - [@dblock](https://github.com/dblock).
* Callbacks receive `team` and `error`, but no longer `server` - [@dblock](https://github.com/dblock).
* [#23](https://github.com/slack-ruby/slack-ruby-bot-server/issues/23): Fix: server-side removal of bot doesn't deactivate it - [@dblock](https://github.com/dblock).

#### 0.3.1 (7/10/2016)

* [#22](https://github.com/slack-ruby/slack-ruby-bot-server/issues/22): Subclassing `SlackRubyBotServer::App` creates an `.instance` of child class - [@dblock](https://github.com/dblock).

#### 0.3.0 (7/4/2016)

* Specify the server class via `SlackRubyBotServer.configure`, default is `SlackRubyBotServer::Server` - [@dblock](https://github.com/dblock).
* Added service management lifecycle callbacks when a new team is registered, deactivated, etc - [@dblock](https://github.com/dblock).

#### 0.2.0 (6/21/2016)

* Relaxed dependency versions, notably enabling grape 0.16.2 and Swagger 0.21.0 that uses Swagger 2.0 spec - [@dblock](https://github.com/dblock).
* [#21](https://github.com/slack-ruby/slack-ruby-bot-server/issues/21): Fix: pass additional options through into `SlackRubyBot::Server` - [@dblock](https://github.com/dblock).

#### 0.1.1 (6/4/2016)

* [#14](https://github.com/slack-ruby/slack-ruby-bot-server/pull/14): Moved config/initializers into the library - [@tmsrjs](https://github.com/tmsrjs).

#### 0.1.0 (6/1/2016)

* Initial public release - [@dblock](https://github.com/dblock).
* Renamed slack-bot-server to slack-ruby-bot-server - [@dblock](https://github.com/dblock).
* [#11](https://github.com/slack-ruby/slack-ruby-bot-server/pull/11): Turn project into gem - [@tmsrjs](https://github.com/tmsrjs).
* Use `celluloid-io` instead of `faye-websocket`, upgrade to slack-ruby-bot 0.8.0 - [@dblock](https://github.com/dblock).
* Fixed `SlackRubyBotServer#reset` - [@dblock](https://github.com/dblock).
* Use Grape 0.15.x - [@dblock](https://github.com/dblock).
* Removed OOB GC - [@dblock](https://github.com/dblock).
* Use Unicorn instead of Puma - [@dblock](https://github.com/dblock).
* Fix: wait for EventMachine reactor to start - [@dblock](https://github.com/dblock).
* Use an OOB GC - [@dblock](https://github.com/dblock).
* Defer start, much faster - [@dblock](https://github.com/dblock).
* Backported changes from slack-metabot and slack-shellbot - [@dblock](https://github.com/dblock).
