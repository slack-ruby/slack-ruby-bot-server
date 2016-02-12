module SlackBotServer
  class App
    def prepare!
      silence_loggers!
      check_mongodb_provider!
      check_database!
      create_indexes!
      mark_teams_active!
      migrate_from_single_team!
      update_team_name_and_id!
      purge_inactive_teams!
      configure_global_aliases!
    end

    def self.instance
      @instance ||= SlackBotServer::App.new
    end

    private

    def logger
      @logger ||= begin
        $stdout.sync = true
        Logger.new(STDOUT)
      end
    end

    def silence_loggers!
      Mongoid.logger.level = Logger::INFO
      Mongo::Logger.logger.level = Logger::INFO
    end

    def check_mongodb_provider!
      return unless ENV['RACK_ENV'] == 'production'
      fail "Missing ENV['MONGO_URL'], ENV['MONGOHQ_URI'] or ENV['MONGOLAB_URI']." unless ENV['MONGO_URL'] || ENV['MONGOHQ_URI'] || ENV['MONGOLAB_URI']
    end

    def check_database!
      rc = Mongoid.default_client.command(ping: 1)
      return if rc && rc.ok?
      fail rc.documents.first['error'] || 'Unexpected error.'
    rescue Exception => e
      warn "Error connecting to MongoDB: #{e.message}"
      raise e
    end

    def create_indexes!
      ::Mongoid::Tasks::Database.create_indexes
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
