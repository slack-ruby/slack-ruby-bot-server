module SlackRubyBotServer
  class Ping
    include Celluloid

    attr_reader :client
    attr_reader :options
    attr_reader :error_count

    def initialize(client, options = {})
      @options = options
      @client = client
      @error_count = 0
      logger.level = Logger::INFO
    end

    def start!
      every ping_interval do
        check!
      end
    end

    private

    def check!
      return if online?
      down!
    rescue StandardError => e
      case e.message
      when 'account_inactive', 'invalid_auth' then
        logger.warn "Error pinging team #{owner.id}: #{e.message}, terminating."
        terminate
      else
        logger.warn "Error pinging team #{owner.id}: #{e.message}."
      end
    end

    def offline?
      !online?
    end

    def online?
      presence.online
    end

    def presence
      owner.ping![:presence]
    end

    def down!
      logger.warn "DOWN: #{owner}, #{retries_left} #{retries_left == 1 ? 'retry' : 'retries'} left"
      @error_count += 1
      return if retries_left?
      restart!
    end

    def restart!
      logger.warn "RESTART: #{owner}"
      driver.emit(:close, WebSocket::Driver::CloseEvent.new(1001, 'bot offline'))
      terminate
    end

    def ping_interval
      options[:ping_interval] || 3 * 60
    end

    def retries_left?
      retries_left >= 0
    end

    def retries_left
      retry_count - error_count
    end

    def retry_count
      options[:retry_count] || 2
    end

    def socket
      client.instance_variable_get(:@socket) if client
    end

    def driver
      socket.instance_variable_get(:@driver) if socket
    end

    def logger
      @logger ||= begin
        $stdout.sync = true
        Logger.new(STDOUT)
      end
    end

    def owner
      client.owner
    end
  end
end
