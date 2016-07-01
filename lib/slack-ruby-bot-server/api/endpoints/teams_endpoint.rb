module SlackRubyBotServer
  module Api
    module Endpoints
      class TeamsEndpoint < Grape::API
        format :json
        helpers Helpers::CursorHelpers
        helpers Helpers::SortHelpers
        helpers Helpers::PaginationParameters

        namespace :teams do
          desc 'Get a team.'
          params do
            requires :id, type: String, desc: 'Team ID.'
          end
          get ':id' do
            team = Team.find(params[:id]) || error!('Not Found', 404)
            present team, with: Presenters::TeamPresenter
          end

          desc 'Get all the teams.'
          params do
            optional :active, type: Boolean, desc: 'Return active teams only.'
            use :pagination
          end
          sort Team::SORT_ORDERS
          get do
            teams = Team.all
            teams = teams.active if params[:active]
            teams = paginate_and_sort_by_cursor(teams, default_sort_order: '-_id')
            present teams, with: Presenters::TeamsPresenter
          end

          desc 'Create a team using an OAuth token.'
          params do
            requires :code, type: String
          end
          post do
            client = Slack::Web::Client.new

            raise 'Missing SLACK_CLIENT_ID or SLACK_CLIENT_SECRET.' unless ENV.key?('SLACK_CLIENT_ID') && ENV.key?('SLACK_CLIENT_SECRET')

            rc = client.oauth_access(
              client_id: ENV['SLACK_CLIENT_ID'],
              client_secret: ENV['SLACK_CLIENT_SECRET'],
              code: params[:code]
            )

            token = rc['bot']['bot_access_token']
            team = Team.where(token: token).first
            team ||= Team.where(team_id: rc['team_id']).first
            if team && !team.active?
              team.activate!(token)
            elsif team
              raise "Team #{team.name} is already registered."
            else
              team = Team.create!(
                token: token,
                team_id: rc['team_id'],
                name: rc['team_name']
              )
            end

            Service.instance.create!(team)
            present team, with: Presenters::TeamPresenter
          end
        end
      end
    end
  end
end
