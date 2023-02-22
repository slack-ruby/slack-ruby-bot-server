# Releasing Slack-Ruby-Bot-Server

There're no hard rules about when to release slack-ruby-bot-server. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
rake
```

Check that the last build succeeded in [Github Actions](https://github.com/slack-ruby/slack-ruby-bot-server/actions) for all supported platforms.

Change "Next" in [CHANGELOG.md](CHANGELOG.md) to the current date.

```
### 2.0.1 (2023/02/20)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Change `**next**` in the "Stable Release" section in README that warns users that they are reading the documentation for an unreleased version with `**stable**`.

```
## Stable Release

You're reading the documentation for the **stable** release of slack-ruby-bot-server, 2.0.1. See [UPGRADING](UPGRADING.md) when upgrading from an older version.
```

Commit your changes.

```
git add README.md CHANGELOG.md
git commit -m "Preparing for release, 2.0.1."
git push origin master
```

Release.

```
$ rake release

slack-ruby-bot-server 2.0.1 built to pkg/slack-ruby-bot-server-2.0.1.gem.
Tagged v2.0.1.
Pushed git commits and tags.
Pushed slack-ruby-bot-server 2.0.1 to rubygems.org.
```

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
### 2.0.2 (Next)

* Your contribution here.
```

Increment the third version number in [lib/slack-ruby-bot-server/version.rb](lib/slack-ruby-bot-server/version.rb).

Undo your change in README about the stable release.

```
## Stable Release

You're reading the documentation for the **next** release of slack-ruby-bot-server. Please see the documentation for the [last stable release, v2.0.1](https://github.com/slack-ruby/slack-ruby-bot-server/blob/v2.0.1/README.md) unless you're integrating with HEAD. See [UPGRADING](UPGRADING.md) when upgrading from an older version. See [MIGRATING](MIGRATING.md) for help with migrating Legacy Slack Apps to Granular Scopes.
```

Commit your changes.

```
git add README.md CHANGELOG.md lib/slack-ruby-bot-server/version.rb
git commit -m "Preparing for next development iteration, 2.0.2."
git push origin master
```
