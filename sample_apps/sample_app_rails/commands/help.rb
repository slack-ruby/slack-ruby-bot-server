class Help < SlackRubyBot::Commands::Base
  HELP = <<-EOS.freeze
```
I am your friendly slack-ruby-bot-server, here to help.

General
-------

help               - get this helpful message
whoami             - print your username

```
  EOS
  def self.call(client, data, _match)
    client.say(channel: data.channel, text: [HELP, SlackRubyBotServer::INFO].join("\n"))
    client.say(channel: data.channel, gif: 'help')
    logger.info "HELP: #{client.owner}, user=#{data.user}"
  end
end
