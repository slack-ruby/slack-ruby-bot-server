require_relative 'methods'

class Team < ActiveRecord::Base
  include Methods

  def self.purge!(dt = 2.weeks.ago)
    Team.where(active: false).where('updated_at <= ?', dt).each do |team|
      begin
        logger.info "Destroying #{team}, inactive since #{team.updated_at}."
        team.destroy
      rescue StandardError => e
        logger.warn "Error destroying #{team}, #{e.message}."
      end
    end
  end
end
