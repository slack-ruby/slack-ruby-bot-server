module SlackRubyBotServer
  class Service
    include SlackRubyBot::Loggable

    def self.start!
      Thread.new do
        Thread.current.abort_on_exception = true
        instance.start_from_database!
      end
    end

    def self.instance
      @instance ||= new
    end

    def initialize
      @lock = Mutex.new
      @services = {}
      @callbacks = Hash.new { |h, k| h[k] = [] }
    end

    def on(type, &block)
      @callbacks[type.to_s] << block
    end

    def create!(team)
      run_callbacks :creating, team
      server = start!(team)
      run_callbacks :created, team, server
    end

    def start!(team)
      raise 'Token already known.' if @services.key?(team.token)
      run_callbacks :starting, team
      logger.info "Starting team #{team}."
      server = SlackRubyBotServer::Config.server_class.new(team: team)
      @lock.synchronize do
        @services[team.token] = server
      end
      start_server! team, server
      run_callbacks :started, team, server
      server
    rescue StandardError => e
      run_callbacks :error, team, nil, e
      logger.error e
    end

    def restart!(team, server, wait = 1)
      run_callbacks :restarting, team, server
      start_server! team, server, wait
      run_callbacks :restarted, team, server
    end

    def stop!(team)
      logger.info "Stopping team #{team}."
      @lock.synchronize do
        raise 'Token unknown.' unless @services.key?(team.token)
        server = @services[team.token]
        run_callbacks :stopping, team, server
        server.stop!
        @services.delete(team.token)
        run_callbacks :stopped, team, server
      end
    rescue StandardError => e
      run_callbacks :error, team, @services[team.token], e
      logger.error e
    end

    def start_from_database!
      Team.active.each do |team|
        run_callbacks :booting, team
        server = start!(team)
        run_callbacks :booted, team, server
      end
    end

    def deactivate!(team)
      @lock.synchronize do
        raise 'Token unknown.' unless @services.key?(team.token)
        server = @services[team.token]
        run_callbacks :deactivating, team, server
        team.deactivate!
        @services.delete(team.token)
        run_callbacks :deactivated, team, server
      end
    rescue Mongoid::Errors::Validations => e
      run_callbacks :error, team, @services[team.token], e
      logger.error "#{team.name}: #{e.message}, error - #{e.document.class}, #{e.document.errors.to_hash}, ignored."
    rescue StandardError => e
      run_callbacks :error, team, @services[team.token], e
      logger.error "#{team.name}: #{e.class}, #{e.message}, ignored."
    end

    def reset!
      run_callbacks :resetting
      @services.values.to_a.each do |server|
        stop!(server.team)
      end
      run_callbacks :reset
    end

    def self.reset!
      @instance.reset! if @instance
      @instance = nil
    end

    private

    def start_server!(team, server, wait = 1)
      server.start_async
    rescue StandardError => e
      run_callbacks :error, team, server, e
      case e.message
      when 'account_inactive', 'invalid_auth' then
        logger.error "#{team.name}: #{e.message}, team will be deactivated."
        deactivate!(team)
      else
        logger.error "#{team.name}: #{e.message}, restarting in #{wait} second(s)."
        sleep(wait)
        start_server! team, server, [wait * 2, 60].min
      end
    end

    def run_callbacks(type, team = nil, server = nil, error = nil)
      callbacks = @callbacks[type.to_s]
      return false unless callbacks
      callbacks.each do |c|
        c.call team, server, error
      end
      true
    rescue StandardError => e
      logger.error e
      false
    end
  end
end
