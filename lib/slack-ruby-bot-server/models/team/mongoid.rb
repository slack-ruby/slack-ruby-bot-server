require_relative 'methods'

class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :team_id, type: String
  field :name, type: String
  field :domain, type: String
  field :token, type: String
  field :oauth_scope, type: String
  field :oauth_version, type: String, default: 'v1'
  field :active, type: Mongoid::Boolean, default: true
  field :bot_user_id, type: String
  field :activated_user_id, type: String
  field :activated_user_access_token, type: String

  include Methods

  def self.purge!(dt = 2.weeks.ago)
    # destroy teams inactive for two weeks
    Team.where(active: false, :updated_at.lte => dt).each do |team|
      begin
        logger.info "Destroying #{team}, inactive since #{team.updated_at}."
        team.destroy
      rescue StandardError => e
        logger.warn "Error destroying #{team}, #{e.message}."
      end
    end
  end
end
