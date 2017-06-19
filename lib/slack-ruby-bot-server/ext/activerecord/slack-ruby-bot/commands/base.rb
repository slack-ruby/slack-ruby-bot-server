module SlackRubyBot
  module Commands
    class Base
      class << self
        alias _invoke invoke

        def invoke(client, data)
          _invoke client, data
        rescue StandardError => e
          logger.info "#{name.demodulize.upcase}: #{client.owner}, #{e.class}: #{e}"
          logger.debug e.backtrace.join("\n")
          client.say(channel: data.channel, text: e.message, gif: 'error')
          true
        end
      end
    end
  end
end
