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

Ensure that you can build the project and run tests.

```
bundle install
bundle exec rake
```

If you are a linux user, you will need to install [geckodriver](https://github.com/mozilla/geckodriver/releases), [firefox](https://download-installer.cdn.mozilla.net/pub/firefox/releases/), and `Xvfb`.  
And, to get a display for the headless browser, run `Xvfb` manually. You can see more explanations [here](http://elementalselenium.com/tips/38-headless).

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

Go back to your pull request after a few minutes and see whether it passed muster with Travis-CI. Everything should look green, otherwise fix issues and amend your commit as described above.

## Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
