module Api
  module Endpoints
    class TeamsEndpoint < Grape::API
      format :json
      helpers Api::Helpers::CursorHelpers
      helpers Api::Helpers::SortHelpers
      helpers Api::Helpers::PaginationParameters

      namespace :teams do
        desc 'Get a team.'
        params do
          requires :id, type: String, desc: 'Team ID.'
        end
        get ':id' do
          team = Team.find(params[:id]) || error!(404, 'Not Found')
          present team, with: Api::Presenters::TeamPresenter
        end

        desc 'Get all the teams.'
        params do
          use :pagination
        end
        get do
          teams = paginate_and_sort_by_cursor(Team)
          present teams, with: Api::Presenters::TeamsPresenter
        end

        desc 'Create a team.'
        params do
          requires :team, type: Hash do
            requires :token, type: String
          end
        end
        post do
          create Team, with: Api::Presenters::TeamPresenter, from: params[:team]
        end

        desc 'Update an existing team.'
        params do
          requires :id, type: String, desc: 'Team id.'
          requires :team, type: Hash do
            optional :token, type: String
          end
        end
        put ':id' do
          team = Team.find(params[:id])
          update team, with: Api::Presenters::TeamPresenter, from: params[:team]
        end

        desc 'Delete an existing team.'
        params do
          requires :id, type: String, desc: 'Team id.'
        end
        delete ':id' do
          team = Team.find(params[:id])
          delete team, with: Api::Presenters::TeamPresenter
        end
      end
    end
  end
end
