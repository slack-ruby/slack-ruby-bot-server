module Api
  module Presenters
    module StatusPresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      link :self do |opts|
        "#{base_url(opts)}/status"
      end

      property :teams_count
      property :active_teams_count
      property :ping

      private

      def ping
        team = Team.asc(:_id).first
        return unless team
        team.ping!
      end

      def teams_count
        Team.count
      end

      def active_teams_count
        Team.active.count
      end

      def base_url(opts)
        request = Grape::Request.new(opts[:env])
        request.base_url
      end
    end
  end
end
