module SlackRubyBotServer
  module Api
    module Presenters
      module TeamsPresenter
        include Roar::JSON::HAL
        include Roar::Hypermedia
        include Grape::Roar::Representer
        include PaginatedPresenter

        collection :results, extend: TeamPresenter, as: :teams, embedded: true
      end
    end
  end
end
