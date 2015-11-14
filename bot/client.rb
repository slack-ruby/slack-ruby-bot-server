module SlackRubyBot
  class Client < Slack::RealTime::Client
    # patch closing of socket not to stop EventMachine and try to restart
    def close(_event)
      super
      restart! unless @stopping
    end

    def stop!
      @stopping = true
      super
    end

    def start!
      @stopping = false
      super
    end

    def restart!(wait = 1)
      EM.next_tick do
        begin
          start!
        rescue StandardError => e
          sleep wait
          logger.error "#{token[0..10]}***: #{e.message}, reconnecting in #{wait} second(s)."
          restart! [wait * 2, 60].min
        end
      end
    end

    def logger
      @logger ||= begin
        $stdout.sync = true
        Logger.new(STDOUT)
      end
    end
  end
end
