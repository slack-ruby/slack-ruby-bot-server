require_relative 'common_methods.rb'
require 'active_record'

class Team < ActiveRecord::Base

  # field :team_id, type: String
  # field :name, type: String
  # field :domain, type: String
  # field :token, type: String
  # field :active, type: Boolean, default: true
  #
  # attr_accessor :server # server at runtime
  include CommonMethods

  def self.purge!
    # destroy teams inactive for two weeks
    Team.where(active: false).where('updated_at <= ?', 2.weeks.ago).each do |team|
      puts "Destroying #{team}, inactive since #{team.updated_at}, over two weeks ago."
      team.destroy
    end
  end
end
