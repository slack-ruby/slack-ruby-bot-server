require_relative 'methods'

class Team < ActiveRecord::Base
  include Methods

  attr_accessor :state

  def self.purge!
    # destroy teams inactive for two weeks
    Team.where(active: false).where('updated_at <= ?', 2.weeks.ago).each do |team|
      puts "Destroying #{team}, inactive since #{team.updated_at}, over two weeks ago."
      team.destroy
    end
  end
end
