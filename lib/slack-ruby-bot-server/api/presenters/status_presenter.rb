module SlackRubyBotServer
  module Api
    module Presenters
      module StatusPresenter
        include Roar::JSON::HAL
        include Roar::Hypermedia
        include Grape::Roar::Representer

        link :self do |opts|
          "#{base_url(opts)}/status"
        end

        property :ping
        property :teams_count
        property :active_teams_count

        def ping
          if SlackRubyBotServer::Config.mongoid?
            team = Team.active.asc(:_id).first
          elsif SlackRubyBotServer::Config.activerecord?
            team = Team.active.last
          else
            raise 'Unsupported database driver.'
          end
          return unless team

          team.ping!
        rescue Slack::Web::Api::Errors::SlackError => e
          raise unless %w[account_inactive invalid_auth].include?(e.message)

          Middleware.logger.warn "Status ping failed for #{team}: #{e.message}; deactivating installation."
          Service.instance.deactivate!(team)
          { ok: false, error: e.message }
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
end
