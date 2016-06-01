## Debugging

### Locally

You can debug your instance of slack-ruby-bot-server with a built-in `script/console`.

### Silence Mongoid Logger

If Mongoid logging is annoying you.

```ruby
Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO
```

### Heroku

```
heroku run script/console --app=...

Running `script/console` attached to terminal... up, run.7593

2.2.1 > Team.count
=> 3
```
