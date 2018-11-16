require_relative 'methods'

module SlackRubyBotServer
  class Team < ActiveRecord::Base
    self.table_name = SlackRubyBotServer::Config.teams_table

    include Methods

    def self.purge!
      # destroy teams inactive for two weeks
      SlackRubyBotServer::Team.where(active: false).where('updated_at <= ?', 2.weeks.ago).each do |team|
        puts "Destroying #{team}, inactive since #{team.updated_at}, over two weeks ago."
        team.destroy
      end
    end
  end
end
