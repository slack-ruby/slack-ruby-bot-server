module Api
  module Endpoints
    class OAuthEndpoint < Grape::API
      format :json

      namespace :oauth do
        desc 'Create a team from an OAuth token.'
        params do
          requires :code, type: String
        end
        post do
          client = Slack::Web::Client.new
          rc = client.oauth_access(client_id: ENV['SLACK_CLIENT_ID'], client_secret: ENV['SLACK_CLIENT_SECRET'], code: params[:code])
          token = rc['bot']['bot_access_token']
          team = create(Team, with: Api::Presenters::TeamPresenter, from: { 'token' => token })
          SlackRubyBot::Service.start! team.token
          team
        end
      end
    end
  end
end
