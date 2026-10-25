# Agent Instructions

## Project

Slack Ruby Bot Server is a Ruby gem providing a Grape API and multi-team Slack bot lifecycle management. Read [CONTRIBUTING.md](CONTRIBUTING.md) before making changes.

- `lib/slack-ruby-bot-server/api/`: endpoints, presenters, helpers, and middleware.
- `lib/slack-ruby-bot-server/models/` and `lib/slack-ruby-bot-server/ext/`: models and database-specific behavior.
- `lib/slack-ruby-bot-server/app.rb` and `service.rb`: application setup and service lifecycle.
- `public/`: registration UI and static assets.
- `spec/`: RSpec API, model, service, and browser integration tests.
- `spec/database_adapters/`: adapter setup, test schemas, and database cleanup.
- `.github/workflows/`: compatibility matrices, lint, and Danger.

## Dependencies and Tests

Set the adapter and version selectors before installing dependencies. Use a Ruby version covered by CI; the examples below match the current Ruby 4/Grape 4 jobs.

Start MongoDB locally, then run:

```sh
export DATABASE_ADAPTER=mongoid MONGOID_VERSION='~> 9.1' GRAPE_VERSION='~> 4.0' JSON_VERSION='~> 3.0'
export DATABASE_URL=mongodb://localhost/slack_ruby_bot_server_test
bundle install
bundle exec rake
```

For PostgreSQL, start the server and adjust local credentials in `DATABASE_URL` as needed:

```sh
export DATABASE_ADAPTER=activerecord ACTIVERECORD_VERSION='~> 8.1' GRAPE_VERSION='~> 4.0' JSON_VERSION='~> 3.0'
export DATABASE_URL=postgresql://localhost/slack_ruby_bot_server_test
bundle install
bundle exec rake
```

Use only a dedicated local test database. The suite deletes or truncates records, and the Active Record schema recreates the teams table.

`bundle exec rake` runs RuboCop and the full RSpec suite. Use `bundle exec rspec path/to/spec.rb` for focused checks. Validate shared behavior against both adapters before committing; batch final checks rather than repeatedly running full suites during editing.

Browser tests require Firefox. Selenium Manager provisions geckodriver when needed. On Linux, install Xvfb and run `xvfb-run --auto-servernum bundle exec rake`. Adapter suites must run sequentially on one host because Capybara uses port 9293.

`Gemfile.lock` is intentionally ignored. Re-resolve dependencies when switching adapter/version combinations; do not add the lockfile to the gem repository.

## Changes and Compatibility

Preserve both database adapters, representative legacy ORM major versions, and the modern Ruby/Grape 3/4 combinations in the six-job-per-adapter CI matrices. Avoid multiplying equivalent jobs across database server versions. Quote version strings in workflow YAML and validate workflow changes with `actionlint`.

Keep JSON 2 constraints scoped to affected legacy matrix jobs through `JSON_VERSION`; modern jobs explicitly test JSON 3. Do not add a blanket JSON upper bound to the Gemfile or gemspec.

Follow existing Ruby conventions and `.rubocop.yml`; do not relax cops or add exclusions just to make checks pass. Add focused regression tests for changed behavior and update directly related documentation. Keep Markdown paragraphs on one line.

Add a changelog entry under the next release, with contributor attribution and the linked PR number once available. Danger checks the changelog and table of contents.

Keep each PR branch to one logical commit. Include `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>` for Copilot contributions, and identify AI-authored GitHub descriptions/comments as posted on behalf of the requesting user. Never force-push `master`. Do not publish a release or push a release tag without explicit authorization.
