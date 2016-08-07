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
      @callbacks = Hash.new { |h, k| h[k] = [] }
    end

    def on(type, &block)
      @callbacks[type.to_s] << block
    end

    def create!(team)
      run_callbacks :creating, team
      start!(team)
      run_callbacks :created, team
    end

    def start!(team)
      run_callbacks :starting, team
      logger.info "Starting team #{team}."
      server = SlackRubyBotServer::Config.server_class.new(team: team)
      start_server! team, server
      run_callbacks :started, team
      server
    rescue StandardError => e
      run_callbacks :error, team, e
      logger.error e
    end

    def restart!(team, server, wait = 1)
      run_callbacks :restarting, team
      start_server! team, server, wait
      run_callbacks :restarted, team
    end

    def stop!(team)
      logger.info "Stopping team #{team}."
      run_callbacks :stopping, team
      team.server.stop! if team.server
      run_callbacks :stopped, team
    rescue StandardError => e
      run_callbacks :error, team, e
      logger.error e
    ensure
      team.server = nil
    end

    def start_from_database!
      Team.active.each do |team|
        run_callbacks :booting, team
        start!(team)
        run_callbacks :booted, team
      end
    end

    def deactivate!(team)
      run_callbacks :deactivating, team
      team.deactivate!
      run_callbacks :deactivated, team
    rescue Mongoid::Errors::Validations => e
      run_callbacks :error, team, e
      logger.error "#{team.name}: #{e.message}, error - #{e.document.class}, #{e.document.errors.to_hash}, ignored."
    rescue StandardError => e
      run_callbacks :error, team, e
      logger.error "#{team.name}: #{e.class}, #{e.message}, ignored."
    ensure
      team.server = nil
    end

    def self.reset!
      @instance = nil
    end

    private

    def start_server!(team, server, wait = 1)
      team.server = server
      server.start_async
    rescue StandardError => e
      run_callbacks :error, team, e
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

    def run_callbacks(type, team = nil, error = nil)
      callbacks = @callbacks[type.to_s]
      return false unless callbacks
      callbacks.each do |c|
        c.call team, error
      end
      true
    rescue StandardError => e
      logger.error e
      false
    end
  end
end
