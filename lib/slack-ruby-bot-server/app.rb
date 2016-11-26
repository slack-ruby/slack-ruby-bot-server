module SlackRubyBotServer
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
      if mongo_setup?
        Mongoid.logger.level = Logger::INFO
        Mongo::Logger.logger.level = Logger::INFO
      end
    end

    def check_mongodb_provider!
      return unless ENV['RACK_ENV'] == 'production'
      unless mongo_setup?
        raise "Missing ENV['MONGO_URL'], ENV['MONGOHQ_URI'], ENV['MONGODB_URI'], or ENV['MONGOLAB_URI']."
      end
    end

    def check_database!
      if mongo_setup?
        begin
          rc = Mongoid.default_client.command(ping: 1)
          return if rc && rc.ok?
          raise rc.documents.first['error'] || 'Unexpected error.'
        rescue Exception => e
          warn "Error connecting to MongoDB: #{e.message}"
          raise e
        end
      elsif postgres_setup?
        connected = ActiveRecord::Base.connection_pool.with_connection { |con| con.active? }  rescue false
        ActiveRecord::Base.connected?
      end
    end

    def create_indexes!
      if mongo_setup?
        ::Mongoid::Tasks::Database.create_indexes
      elsif postgres_setup?
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

    def mongo_setup?
      !!(ENV['MONGO_URL'] || ENV['MONGOHQ_URI'] || ENV['MONGODB_URI'] || ENV['MONGOLAB_URI'])
    end

    def postgres_setup?
      !!ENV['SLACK_BOT_POSTGRES_URL']
    end
  end
end
