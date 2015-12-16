module Api
  module Endpoints
    class RootEndpoint < Grape::API
      include Api::Helpers::ErrorHelpers

      prefix 'api'

      format :json
      formatter :json, Grape::Formatter::Roar

      get do
        present self, with: Api::Presenters::RootPresenter
      end

      mount Api::Endpoints::TeamsEndpoint
      mount Api::Endpoints::OAuthEndpoint

      add_swagger_documentation
    end
  end
end
