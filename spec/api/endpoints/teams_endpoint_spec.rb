require 'spec_helper'

describe SlackRubyBotServer::Api::Endpoints::TeamsEndpoint do
  include SlackRubyBotServer::Api::Test::EndpointTest

  it_behaves_like 'a cursor api', Team

  context 'team' do
    let(:existing_team) { Fabricate(:team) }
    it 'returns a team' do
      team = client.team(id: existing_team.id)
      expect(team.id.to_s).to eq existing_team.id.to_s
      expect(team._links.self._url).to eq "http://example.org/api/teams/#{existing_team.id}"
    end
  end

  context 'teams' do
    context 'active/inactive' do
      let!(:active_team) { Fabricate(:team, active: true) }
      let!(:inactive_team) { Fabricate(:team, active: false) }
      it 'returns all teams' do
        teams = client.teams
        expect(teams.count).to eq 2
      end
      it 'returns active teams' do
        teams = client.teams(active: true)
        expect(teams.count).to eq 1
        expect(teams.to_a.first.team_id).to eq active_team.team_id
      end
    end
  end

  context 'team' do
    let(:existing_team) { Fabricate(:team) }
    it 'returns a team' do
      team = client.team(id: existing_team.id)
      expect(team.id.to_s).to eq existing_team.id.to_s
    end

    it 'requires code' do
      expect { client.teams._post }.to raise_error Faraday::ClientError do |e|
        json = JSON.parse(e.response[:body])
        expect(json['message']).to eq 'Invalid parameters.'
        expect(json['type']).to eq 'param_error'
      end
    end

    context 'register a bot via oauth v2' do
      before do
        SlackRubyBotServer.config.oauth_version = :v2
        oauth_access = Slack::Messages::Message.new(
          'access_token' => 'access_token',
          'scope' => 'commands,incoming-webhook',
          'authed_user' => { 'id' => 'user_id' },
          'team' => { 'id' => 'team_id', 'name' => 'team_name' }
        )
        ENV['SLACK_CLIENT_ID'] = 'client_id'
        ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
        allow_any_instance_of(Slack::Web::Client).to receive(:oauth_v2_access).with(
          hash_including(
            code: 'code',
            client_id: 'client_id',
            client_secret: 'client_secret'
          )
        ).and_return(oauth_access)
      end
      after do
        ENV.delete('SLACK_CLIENT_ID')
        ENV.delete('SLACK_CLIENT_SECRET')
      end
      it 'creates a team' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq 'team_id'
          expect(team.name).to eq 'team_name'
          team = Team.find(team.id)
          expect(team.token).to eq 'access_token'
          expect(team.oauth_version).to eq 'v2'
          expect(team.oauth_scope).to eq 'commands,incoming-webhook'
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to be nil
        end.to change(Team, :count).by(1)
      end

      it 'includes optional state parameter' do
        expect(SlackRubyBotServer::Service.instance).to receive(:create!).with(instance_of(Team), { state: 'property' })
        client.teams._post(code: 'code', state: 'property')
      end

      it 'reactivates a deactivated team' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'access_token', active: false)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'access_token'
          expect(team.oauth_version).to eq 'v2'
          expect(team.oauth_scope).to eq 'commands,incoming-webhook'
          expect(team.active).to be true
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to be nil
        end.to_not change(Team, :count)
      end
      it 'reactivates a team deactivated on slack' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'access_token')
        expect do
          expect_any_instance_of(Team).to receive(:ping!) { raise Slack::Web::Api::Errors::SlackError, 'invalid_auth' }
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'access_token'
          expect(team.oauth_version).to eq 'v2'
          expect(team.oauth_scope).to eq 'commands,incoming-webhook'
          expect(team.active).to be true
          expect(team.bot_user_id).to be nil
          expect(team.activated_user_id).to eq 'user_id'
        end.to_not change(Team, :count)
      end
      it 'returns a useful error when team already exists' do
        expect_any_instance_of(Team).to receive(:ping_if_active!)
        existing_team = Fabricate(:team, token: 'access_token')
        expect { client.teams._post(code: 'code') }.to raise_error Faraday::ClientError do |e|
          json = JSON.parse(e.response[:body])
          expect(json['message']).to eq "Team #{existing_team.name} is already registered."
        end
      end
      it 'reactivates a deactivated team with a different code' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'old', team_id: 'team_id', active: false)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'access_token'
          expect(team.oauth_version).to eq 'v2'
          expect(team.oauth_scope).to eq 'commands,incoming-webhook'
          expect(team.active).to be true
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to be nil
        end.to_not change(Team, :count)
      end
    end

    context 'register a bot via oauth v1' do
      before do
        SlackRubyBotServer.config.oauth_version = :v1
        oauth_access = Slack::Messages::Message.new(
          'access_token' => 'access_token',
          'scope' => 'incoming-webhook,commands,bot',
          'user_id' => 'user_id',
          'team_id' => 'team_id',
          'team_name' => 'team_name'
        )
        ENV['SLACK_CLIENT_ID'] = 'client_id'
        ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
        allow_any_instance_of(Slack::Web::Client).to receive(:oauth_access).with(
          hash_including(
            code: 'code',
            client_id: 'client_id',
            client_secret: 'client_secret'
          )
        ).and_return(oauth_access)
      end
      after do
        ENV.delete('SLACK_CLIENT_ID')
        ENV.delete('SLACK_CLIENT_SECRET')
      end
      it 'creates a team' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq 'team_id'
          expect(team.name).to eq 'team_name'
          team = Team.find(team.id)
          expect(team.token).to eq 'access_token'
          expect(team.oauth_version).to eq 'v1'
          expect(team.oauth_scope).to eq 'incoming-webhook,commands,bot'
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to be nil
        end.to change(Team, :count).by(1)
      end

      it 'includes optional state parameter' do
        expect(SlackRubyBotServer::Service.instance).to receive(:create!).with(instance_of(Team), { state: 'property' })
        client.teams._post(code: 'code', state: 'property')
      end

      it 'reactivates a deactivated team' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'access_token', active: false)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'access_token'
          expect(team.oauth_version).to eq 'v1'
          expect(team.oauth_scope).to eq 'incoming-webhook,commands,bot'
          expect(team.active).to be true
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to be nil
        end.to_not change(Team, :count)
      end
      it 'reactivates a team deactivated on slack' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'access_token')
        expect do
          expect_any_instance_of(Team).to receive(:ping!) { raise Slack::Web::Api::Errors::SlackError, 'invalid_auth' }
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'access_token'
          expect(team.oauth_version).to eq 'v1'
          expect(team.oauth_scope).to eq 'incoming-webhook,commands,bot'
          expect(team.active).to be true
          expect(team.bot_user_id).to be nil
          expect(team.activated_user_id).to eq 'user_id'
        end.to_not change(Team, :count)
      end
      it 'returns a useful error when team already exists' do
        expect_any_instance_of(Team).to receive(:ping_if_active!)
        existing_team = Fabricate(:team, token: 'access_token')
        expect { client.teams._post(code: 'code') }.to raise_error Faraday::ClientError do |e|
          json = JSON.parse(e.response[:body])
          expect(json['message']).to eq "Team #{existing_team.name} is already registered."
        end
      end
      it 'reactivates a deactivated team with a different code' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'old', team_id: 'team_id', active: false)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'access_token'
          expect(team.oauth_version).to eq 'v1'
          expect(team.oauth_scope).to eq 'incoming-webhook,commands,bot'
          expect(team.active).to be true
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to be nil
        end.to_not change(Team, :count)
      end
    end

    context 'register a legacy bot' do
      before do
        SlackRubyBotServer.config.oauth_version = :v1
        oauth_access = Slack::Messages::Message.new(
          'bot' => {
            'bot_access_token' => 'token',
            'bot_user_id' => 'bot_user_id'
          },
          'access_token' => 'access_token',
          'scope' => 'incoming-webhook,commands,bot',
          'user_id' => 'user_id',
          'team_id' => 'team_id',
          'team_name' => 'team_name'
        )
        ENV['SLACK_CLIENT_ID'] = 'client_id'
        ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
        allow_any_instance_of(Slack::Web::Client).to receive(:oauth_access).with(
          hash_including(
            code: 'code',
            client_id: 'client_id',
            client_secret: 'client_secret'
          )
        ).and_return(oauth_access)
      end
      after do
        ENV.delete('SLACK_CLIENT_ID')
        ENV.delete('SLACK_CLIENT_SECRET')
      end
      it 'creates a team' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq 'team_id'
          expect(team.name).to eq 'team_name'
          team = Team.find(team.id)
          expect(team.token).to eq 'token'
          expect(team.oauth_version).to eq 'v1'
          expect(team.oauth_scope).to eq 'incoming-webhook,commands,bot'
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to eq 'bot_user_id'
        end.to change(Team, :count).by(1)
      end

      it 'includes optional state parameter' do
        expect(SlackRubyBotServer::Service.instance).to receive(:create!).with(instance_of(Team), { state: 'property' })
        client.teams._post(code: 'code', state: 'property')
      end

      it 'reactivates a deactivated team' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'token', active: false)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'token'
          expect(team.oauth_version).to eq 'v1'
          expect(team.oauth_scope).to eq 'incoming-webhook,commands,bot'
          expect(team.active).to be true
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to eq 'bot_user_id'
        end.to_not change(Team, :count)
      end
      it 'reactivates a team deactivated on slack' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'token')
        expect do
          expect_any_instance_of(Team).to receive(:ping!) { raise Slack::Web::Api::Errors::SlackError, 'invalid_auth' }
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'token'
          expect(team.oauth_version).to eq 'v1'
          expect(team.oauth_scope).to eq 'incoming-webhook,commands,bot'
          expect(team.active).to be true
          expect(team.bot_user_id).to eq 'bot_user_id'
          expect(team.activated_user_id).to eq 'user_id'
        end.to_not change(Team, :count)
      end
      it 'returns a useful error when team already exists' do
        expect_any_instance_of(Team).to receive(:ping_if_active!)
        existing_team = Fabricate(:team, token: 'token')
        expect { client.teams._post(code: 'code') }.to raise_error Faraday::ClientError do |e|
          json = JSON.parse(e.response[:body])
          expect(json['message']).to eq "Team #{existing_team.name} is already registered."
        end
      end
      it 'reactivates a deactivated team with a different code' do
        expect(SlackRubyBotServer::Service.instance).to receive(:start!)
        existing_team = Fabricate(:team, token: 'old', team_id: 'team_id', active: false)
        expect do
          team = client.teams._post(code: 'code')
          expect(team.team_id).to eq existing_team.team_id
          expect(team.name).to eq existing_team.name
          expect(team.active).to be true
          team = Team.find(team.id)
          expect(team.token).to eq 'token'
          expect(team.oauth_version).to eq 'v1'
          expect(team.oauth_scope).to eq 'incoming-webhook,commands,bot'
          expect(team.active).to be true
          expect(team.activated_user_access_token).to eq 'access_token'
          expect(team.activated_user_id).to eq 'user_id'
          expect(team.bot_user_id).to eq 'bot_user_id'
        end.to_not change(Team, :count)
      end
    end
  end
end
