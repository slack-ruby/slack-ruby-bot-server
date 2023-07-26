require_relative '../../models/team/activerecord.rb'

require 'pagy'
require 'pagy_cursor/pagy/extras/cursor'

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
      return if ActiveRecord::Base.connection.tables.include?('teams')

      ActiveRecord::Base.connection.create_table :teams do |t|
        t.string :team_id
        t.string :name
        t.string :domain
        t.string :token
        t.string :oauth_scope
        t.string :oauth_version, default: 'v1', null: false
        t.string :bot_user_id
        t.string :activated_user_id
        t.string :activated_user_access_token
        t.boolean :active, default: true
        t.timestamps
      end
    end
  end
end

Boolean = Grape::API::Boolean
