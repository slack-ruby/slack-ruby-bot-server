require 'slack-ruby-bot-server/models/team/activerecord.rb'

module SlackRubyBotServer
  module DatabaseAdapter
    def self.check!
      ActiveRecord::Base.connection_pool.with_connection(&:active?)
      raise 'Unexpected error.' unless ActiveRecord::Base.connected?
    rescue StandardError => e
      warn "Error connecting to PostgreSQL: #{e.message}"
      raise e
    end

    def self.init!
      return if ActiveRecord::Base.connection.tables.include?(SlackRubyBotServer::Config.teams[:name].to_s)
      ActiveRecord::Base.connection.create_table SlackRubyBotServer::Config.teams[:name] do |t|
        t.string :team_id
        t.string :name
        t.string :domain
        t.string :token
        t.boolean :active, default: true
        t.timestamps
      end
    end
  end
end

::Boolean = Virtus::Attribute::Boolean
