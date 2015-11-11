module SlackRubyBot
  class Service
    LOCK = Mutex.new
    @services = {}

    class << self
      def start!(token)
        fail 'Token already known.' if @services.key?(token)
        Thread.new do
          begin
            server = SlackRubyBot::Server.new(token: token)
            LOCK.synchronize do
              @services[token] = server
            end
            server.send(:auth!)
            server.send(:start!)
          rescue Exception => e
            logger.error e
            raise e
          end
        end
      rescue Exception => e
        logger.error e
      end

      def stop!(token)
        LOCK.synchronize do
          fail 'Token unknown.' unless @services.key?(token)
          @services[token].stop!
          @services.delete(token)
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
    end
  end
end
