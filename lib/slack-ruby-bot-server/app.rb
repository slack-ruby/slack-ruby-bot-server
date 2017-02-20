module SlackRubyBotServer
  class App
    def prepare!
      silence_loggers!
      check_database!
      create_indexes!
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

    def silence_loggers!
      return unless SlackRubyBotServer::Config.mongoid?
      Mongoid.logger.level = Logger::INFO
      Mongo::Logger.logger.level = Logger::INFO
    end

    def check_database!
      if SlackRubyBotServer::Config.mongoid?
        begin
          rc = Mongoid.default_client.command(ping: 1)
          return if rc && rc.ok?
          raise rc.documents.first['error'] || 'Unexpected error.'
        rescue Exception => e
          warn "Error connecting to MongoDB: #{e.message}"
          raise e
        end
      elsif SlackRubyBotServer::Config.pg?
        begin
          ActiveRecord::Base.connection_pool.with_connection(&:active?) rescue false
          warn "Error connecting to PostgreSQL: ActiveRecord cannot connect." unless ActiveRecord::Base.connected?
        rescue Exception => e
          warn "Error connecting to PostgreSQL: #{e.message}"
          raise e
        end
      end
    end

    def create_indexes!
      if SlackRubyBotServer::Config.mongoid?
        ::Mongoid::Tasks::Database.create_indexes
      elsif SlackRubyBotServer::Config.pg?
        unless ActiveRecord::Base.connection.tables.include?('teams')
          ActiveRecord::Base.connection.create_table :teams do |t|
            t.string :team_id
            t.string :name
            t.string :domain
            t.string :token
            t.boolean :active
            t.timestamps
          end
        end
      end
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
