require_relative '../../models/team/mongoid.rb'

require 'kaminari/grape'
require 'mongoid-scroll'

module SlackRubyBotServer
  module DatabaseAdapter
    def self.check!
      rc = Mongoid.default_client.command(ping: 1)
      return if rc&.ok?

      raise rc.documents.first['error'] || 'Unexpected error.'
    rescue StandardError => e
      warn "Error connecting to MongoDB: #{e.message}"
      raise e
    end

    def self.init!
      # create indexes
      ::Mongoid::Tasks::Database.create_indexes
      # silence loggers
      Mongoid.logger.level = Logger::INFO
      Mongo::Logger.logger.level = Logger::INFO
    end
  end
end

::Boolean = Grape::API::Boolean
