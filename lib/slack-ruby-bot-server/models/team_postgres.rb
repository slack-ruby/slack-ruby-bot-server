require_relative 'common_methods.rb'
require 'active_record'

class Team < ActiveRecord::Base

  include CommonMethods

  def self.purge!
    # destroy teams inactive for two weeks
    Team.where(active: false).where('updated_at <= ?', 2.weeks.ago).each do |team|
      puts "Destroying #{team}, inactive since #{team.updated_at}, over two weeks ago."
      team.destroy
    end
  end
end
