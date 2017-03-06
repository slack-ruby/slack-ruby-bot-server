This app is deployed from [github.com/slack-ruby/slack-ruby-bot-server-sample](https://github.com/slack-ruby/slack-ruby-bot-server-sample).

[Register a new Slack app](https://api.slack.com/apps), configure a bot user, and OAuth redirect URL to http://localhost:9292 (for development). Configure your development environment by editing `.env` and setting the client ID and secret you were given during registration:

    SLACK_CLIENT_ID=1111111111.2222222
    SLACK_CLIENT_SECRET=abcdef012345679
    PORT=9292

Run tests with:

    bundle exec rake


