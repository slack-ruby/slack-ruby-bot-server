module SlackRubyBotServer
  class Ping
    attr_reader :client
    attr_reader :options
    attr_reader :error_count

    def initialize(client, options = {})
      @options = options
      @client = client
      @error_count = 0
    end

    def start!
      ::Async::Reactor.run do |task|
        run(task)
      end
    end

    private

    def run(task)
      logger.debug "PING: #{owner}, every #{ping_interval} second(s)"
      loop do
        task.sleep ping_interval
        break unless check!
      end
      logger.debug "PING: #{owner}, done."
    rescue StandardError => e
      logger.error e
      raise e
    end

    def check!
      if online?
        @error_count = 0
        true
      else
        down!
      end
    rescue StandardError => e
      case e.message
      when 'account_inactive', 'invalid_auth' then
        logger.warn "Error pinging team #{owner.id}: #{e.message}, terminating."
        false
      else
        logger.warn "Error pinging team #{owner.id}: #{e.message}."
        true
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
      return true if retries_left?
      restart!
      false
    end

    def restart!
      logger.warn "RESTART: #{owner}"
      driver.close if driver
    rescue StandardError => e
      logger.warn "Error restarting team #{owner.id}: #{e.message}."
    end

    def ping_interval
      options[:ping_interval] || 60
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
        STDOUT.sync = true
        Logger.new(STDOUT)
      end
    end

    def owner
      client.owner
    end
  end
end
