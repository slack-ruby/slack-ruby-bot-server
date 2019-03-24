module SlackRubyBotServer
  class App
    def prepare!
      check_database!
      init_database!
      mark_teams_active!
      update_team_name_and_id!
      purge_inactive_teams!
      configure_global_aliases!
    end

    def self.instance
      @instance ||= new
    end

    private

    def logger
      @logger ||= begin
        STDOUT.sync = true
        Logger.new(STDOUT)
      end
    end

    def check_database!
      SlackRubyBotServer::DatabaseAdapter.check!
    end

    def init_database!
      SlackRubyBotServer::DatabaseAdapter.init!
    end

    def mark_teams_active!
      Team.where(active: nil).update_all(active: true)
    end

    def update_team_name_and_id!
      Team.active.where(team_id: nil).each do |team|
        begin
          auth = team.ping![:auth]
          team.update_attributes!(team_id: auth['team_id'], name: auth['team'])
        rescue StandardError => e
          logger.warn "Error pinging team #{team.id}: #{e.message}."
          team.set(active: false)
        end
      end
    end

    def purge_inactive_teams!
      Team.purge!
    end

    def configure_global_aliases!
      SlackRubyBot.configure do |config|
        config.aliases = ENV['SLACK_RUBY_BOT_ALIASES'].split(' ') if ENV['SLACK_RUBY_BOT_ALIASES']
      end
    end
  end
end
