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

        property :teams_count
        property :active_teams_count
        property :ping

        def ping
          if SlackRubyBotServer::Config.mongoid?
            team = SlackRubyBotServer::Team.asc(:_id).first
          elsif SlackRubyBotServer::Config.activerecord?
            team = SlackRubyBotServer::Team.last
          else
            raise 'Unsupported database driver.'
          end
          return unless team
          team.ping!
        end

        def teams_count
          SlackRubyBotServer::Team.count
        end

        def active_teams_count
          SlackRubyBotServer::Team.active.count
        end

        def base_url(opts)
          request = Grape::Request.new(opts[:env])
          request.base_url
        end
      end
    end
  end
end
