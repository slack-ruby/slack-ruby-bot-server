module SlackRubyBotServer
  class App
    include SlackRubyBotServer::Loggable

    def prepare!
      check_database!
      init_database!
      purge_inactive_teams!
    end

    def self.instance
      @instance ||= new
    end

    private

    def check_database!
      SlackRubyBotServer::DatabaseAdapter.check!
    end

    def init_database!
      SlackRubyBotServer::DatabaseAdapter.init!
    end

    def purge_inactive_teams!
      Team.purge!
    end
  end
end
