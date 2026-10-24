# Contributing to SlackRubyBotServer

This project is work of [many contributors](https://github.com/slack-ruby/slack-ruby-bot-server/graphs/contributors).

You're encouraged to submit [pull requests](https://github.com/slack-ruby/slack-ruby-bot-server/pulls), [propose features and discuss issues](https://github.com/slack-ruby/slack-ruby-bot-server/issues).

In the examples below, substitute your Github username for `contributor` in URLs.

## Fork the Project

Fork the [project on Github](https://github.com/slack-ruby/slack-ruby-bot-server) and check out your copy.

```
git clone https://github.com/contributor/slack-ruby-bot-server.git
cd slack-ruby-bot-server
git remote add upstream https://github.com/slack-ruby/slack-ruby-bot-server.git
```

## Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

## Bundle Install and Test

Select a database adapter before installing dependencies. For example, to match the Ruby 4 MongoDB/Grape 4 job, start MongoDB locally and run:

```sh
export DATABASE_ADAPTER=mongoid MONGOID_VERSION='~> 9.1' GRAPE_VERSION='~> 4.0' JSON_VERSION='~> 3.0'
export DATABASE_URL=mongodb://localhost/slack_ruby_bot_server_test
bundle install
bundle exec rake
```

For PostgreSQL, set `DATABASE_ADAPTER=activerecord`, `ACTIVERECORD_VERSION`, and `DATABASE_URL` instead. `GRAPE_VERSION` optionally constrains the Grape version for either adapter; without it, Bundler selects a compatible version. CI preserves the older compatibility combinations and adds explicit Grape 3 and 4 jobs with current ORM versions, including Ruby 4. Each database runs in a health-checked service container, while Firefox runs under Xvfb. Selenium Manager provisions the matching driver.

`JSON_VERSION` optionally constrains the development/test JSON dependency; otherwise it is unrestricted. CI uses JSON 2 for Mongoid 6-8 and Active Record 6.x, 7.0, and 8.0 because their Active Support versions pass `quirks_mode`, removed in JSON 3. Mongoid 9, Active Record 7.2, and Active Record 8.1 jobs explicitly test JSON 3. These selectors do not restrict the published gem's runtime dependencies.

On Linux, install [Firefox](https://www.mozilla.org/firefox/) and `Xvfb`, then run:

```
xvfb-run --auto-servernum bundle exec rake
```

## Write Tests

Try to write a test that reproduces the problem you're trying to fix or describes a feature that you want to build.
Add to [spec](spec).

We definitely appreciate pull requests that highlight or reproduce a problem, even without a fix.

## Write Code

Implement your feature or bug fix.

Ruby style is enforced with [Rubocop](https://github.com/bbatsov/rubocop).
Run `bundle exec rubocop` and fix any style issues highlighted.

Make sure that `bundle exec rake` completes without errors.

## Write Documentation

Document any external behavior in the [README](README.md).

## Update Changelog

Add a line to [CHANGELOG](CHANGELOG.md) under *Next Release*.
Make it look like every other line, including your name and link to your Github account.

## Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

## Push

```
git push origin my-feature-branch
```

## Make a Pull Request

Go to https://github.com/contributor/slack-ruby-bot-server and select your feature branch.
Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

## Rebase

If you've been working on a change for a while, rebase with upstream/master.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```

## Update CHANGELOG Again

Update the [CHANGELOG](CHANGELOG.md) with the pull request number. A typical entry looks as follows.

```
* [#123](https://github.com/slack-ruby/slack-ruby-bot-server/pull/123): Reticulated splines - [@contributor](https://github.com/contributor).
```

Amend your previous commit and force push the changes.

```
git commit --amend
git push origin my-feature-branch -f
```

## Check on Your Pull Request

Go back to your pull request after a few minutes and check its GitHub Actions results. Everything should look green, otherwise fix issues and update your commit as described above.

## Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
