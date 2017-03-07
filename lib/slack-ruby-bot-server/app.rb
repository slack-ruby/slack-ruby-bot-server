module SlackRubyBotServer
  class App
    def prepare!
      check_database!
      init_database!
      mark_teams_active!
      migrate_from_single_team!
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
        $stdout.sync = true
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

    def migrate_from_single_team!
      return unless ENV.key?('SLACK_API_TOKEN')
      logger.info 'Migrating from env SLACK_API_TOKEN ...'
      team = Team.find_or_create_from_env!
      logger.info "Automatically migrated team: #{team}."
      logger.warn "You should unset ENV['SLACK_API_TOKEN']."
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
