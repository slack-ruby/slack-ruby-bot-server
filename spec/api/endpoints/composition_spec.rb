require 'spec_helper'

describe 'API composition' do
  include Rack::Test::Methods

  let(:app) { SlackRubyBotServer::Api::Middleware.instance }

  it 'adds custom routes alongside the default API in the shared middleware stack' do
    extra = Class.new(Grape::API) do
      prefix 'api'
      format :json
      get(:foobar) { { ok: true } }
    end
    custom = Class.new(Grape::API) do
      mount SlackRubyBotServer::Api::Endpoints::RootEndpoint
      mount extra
    end
    SlackRubyBotServer.config.api = custom

    get '/api/foobar', {}, 'HTTP_ORIGIN' => 'https://example.org'
    expect(JSON.parse(last_response.body)).to eq('ok' => true)
    expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
    get '/api'
    expect(last_response.status).to eq 200
  end

  it 'restores the default API when configuration is reset' do
    SlackRubyBotServer.config.api = ->(_env) { [418, {}, ['Custom API']] }
    get '/api'
    expect(last_response.status).to eq 418
    SlackRubyBotServer.config.reset!
    get '/api'
    expect(last_response.status).to eq 200
  end

  context 'with only registration mounted' do
    before do
      SlackRubyBotServer.config.api = Class.new(Grape::API) do
        include SlackRubyBotServer::Api::Helpers::ErrorHelpers

        prefix 'api'
        format :json
        formatter :json, Grape::Formatter::Roar
        mount SlackRubyBotServer::Api::Endpoints::TeamsEndpoint::Create
      end
    end

    it 'does not expose the team list or individual records' do
      team = Fabricate(:team)
      get '/api/teams'
      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)['message']).to eq '405 Not Allowed'
      get "/api/teams/#{team.id}"
      expect(last_response.status).to eq 404
      expect(last_response.body).not_to include(team.token)
    end

    it 'keeps OAuth registration available' do
      oauth = Slack::Messages::Message.new(
        'access_token' => 'registration-only-token',
        'scope' => 'chat:write',
        'team' => { 'id' => 'TREGISTRATION', 'name' => 'Registration only' }
      )
      allow(ENV).to receive(:key?).and_call_original
      allow(ENV).to receive(:key?).with('SLACK_CLIENT_ID').and_return(true)
      allow(ENV).to receive(:key?).with('SLACK_CLIENT_SECRET').and_return(true)
      allow_any_instance_of(Slack::Web::Client).to receive(:oauth_v2_access).and_return(oauth)

      expect { post '/api/teams', code: 'authorization-code' }.to change(Team, :count).by(1)
      expect(last_response.status).to eq 201
      expect(Team.find_by(team_id: 'TREGISTRATION').token).to eq 'registration-only-token'
    end
  end
end
