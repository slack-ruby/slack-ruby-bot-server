module SlackRubyBotServer
  module Api
    module Endpoints
      class RootEndpoint < Grape::API
        include Helpers::ErrorHelpers

        prefix 'api'

        format :json
        formatter :json, Grape::Formatter::Roar
        get do
          present self, with: Presenters::RootPresenter
        end

        mount StatusEndpoint
        mount TeamsEndpoint

        add_swagger_documentation
      end
    end
  end
end
