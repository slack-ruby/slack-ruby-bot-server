module Api
  module Endpoints
    class RootEndpoint < Grape::API
      prefix 'api'

      format :json
      formatter :json, Grape::Formatter::Roar

      get do
        present self, with: Api::Presenters::RootPresenter
      end

      mount Api::Endpoints::TeamsEndpoint

      add_swagger_documentation
    end
  end
end
