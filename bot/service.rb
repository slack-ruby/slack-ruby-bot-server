module SlackRubyBot
  class Service
    LOCK = Mutex.new
    @services = {}

    class << self
      def start!(token)
        fail 'Token already known.' if @services.key?(token)
        EM.next_tick do
          server = SlackRubyBot::Server.new(token: token)
          LOCK.synchronize do
            @services[token] = server
          end
          restart!(server)
        end
      rescue Exception => e
        logger.error e
      end

      def stop!(token)
        LOCK.synchronize do
          fail 'Token unknown.' unless @services.key?(token)
          EM.next_tick do
            @services[token].stop!
            @services.delete(token)
          end
        end
      rescue Exception => e
        logger.error e
      end

      def logger
        @logger ||= begin
          $stdout.sync = true
          Logger.new(STDOUT)
        end
      end

      def start_from_database!
        Team.each do |team|
          start! team.token
        end
      end

      def restart!(server, wait = 1)
        server.auth!
        server.start!
      rescue Exception => e
        logger.error "#{server.token[0..10]}***: #{e.message}, restarting in #{wait} second(s)."
        sleep(wait)
        EM.next_tick do
          restart! server, [wait * 2, 60].min
        end
      end
    end
  end
end
