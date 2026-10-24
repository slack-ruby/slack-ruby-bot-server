# Releasing Slack-Ruby-Bot-Server

There're no hard rules about when to release slack-ruby-bot-server. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Start from a clean, up-to-date canonical checkout on `master`. Confirm that the version in `lib/slack-ruby-bot-server/version.rb` matches the next changelog heading and has not already been published on RubyGems or tagged in Git.

Run the tests against dedicated local test databases as described in [CONTRIBUTING.md](CONTRIBUTING.md). Set the adapter and version selectors before installing dependencies. For example, with Ruby 4 and MongoDB running locally:

```sh
export DATABASE_ADAPTER=mongoid MONGOID_VERSION='~> 9.1' GRAPE_VERSION='~> 4.0' JSON_VERSION='~> 3.0'
export DATABASE_URL=mongodb://localhost/slack_ruby_bot_server_test
bundle install
bundle exec rake
```

Also validate the Active Record adapter with its own test database. Do not run adapter suites concurrently on one host; browser tests share port 9293. Never use a production database.

Check that [GitHub Actions](https://github.com/slack-ruby/slack-ruby-bot-server/actions) succeeded for the release commit across both database matrices and RuboCop. A successful build for a different commit is not sufficient.

Change "Next" in [CHANGELOG.md](CHANGELOG.md) to the current date.

```
### 2.2.1 (2026/10/24)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Change `**next**` in the "Stable Release" section in README that warns users that they are reading the documentation for an unreleased version with `**stable**`.

```
## Stable Release

You're reading the documentation for the **stable** release of slack-ruby-bot-server, 2.2.1. See [UPGRADING](UPGRADING.md) when upgrading from an older version. See [MIGRATING](MIGRATING.md) for help with migrating Legacy Slack Apps to Granular Scopes.
```

Commit your changes.

```
git add README.md CHANGELOG.md RELEASING.md
git commit -m "Preparing for release, 2.2.1."
git push origin master
```

Wait for the release commit's GitHub Actions checks to succeed before publishing.

RubyGems publishing requires a maintainer's credentials and may require a fresh one-time password (OTP). For an agent-assisted release, ask the maintainer for the OTP immediately before publishing, after tests, commits, and CI are complete. Use it only for the publishing process; never put OTPs or API keys in committed files, release notes, or logs.

Pass the temporary code through `GEM_HOST_OTP_CODE`. With `OTP` holding the freshly supplied code:

```sh
GEM_HOST_OTP_CODE="$OTP" bundle exec rake release
unset OTP
```

The release task builds the gem in `pkg/`, tags the release, pushes commits and the tag, and publishes to RubyGems. Confirm that the remote tag points to the release commit and that RubyGems lists the expected version before proceeding. If publishing fails, inspect which steps completed before retrying; do not move an existing release tag or overwrite a published version.

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
### 2.2.2 (Next)

* Your contribution here.
```

Increment the third version number in [lib/slack-ruby-bot-server/version.rb](lib/slack-ruby-bot-server/version.rb).

Undo your change in README about the stable release.

```
## Stable Release

You're reading the documentation for the **next** release of slack-ruby-bot-server. Please see the documentation for the [last stable release, v2.2.1](https://github.com/slack-ruby/slack-ruby-bot-server/blob/v2.2.1/README.md) unless you're integrating with HEAD. See [UPGRADING](UPGRADING.md) when upgrading from an older version. See [MIGRATING](MIGRATING.md) for help with migrating Legacy Slack Apps to Granular Scopes.
```

Commit your changes.

```
git add README.md CHANGELOG.md lib/slack-ruby-bot-server/version.rb
git commit -m "Preparing for next development iteration, 2.2.2."
git push origin master
```
