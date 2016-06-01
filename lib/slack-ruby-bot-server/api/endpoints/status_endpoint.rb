module SlackRubyBotServer
  module Api
    module Endpoints
      class StatusEndpoint < Grape::API
        format :json

        namespace :status do
          desc 'Get system status.'
          get do
            present self, with: Presenters::StatusPresenter
          end
        end
      end
    end
  end
end
