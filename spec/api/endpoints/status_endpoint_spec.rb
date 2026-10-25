require 'spec_helper'

describe SlackRubyBotServer::Api::Endpoints::StatusEndpoint do
  include SlackRubyBotServer::Api::Test::EndpointTest

  before do
    allow_any_instance_of(Team).to receive(:ping!).and_return(ok: 1)
  end

  context 'status' do
    it 'returns a status' do
      status = client.status
      expect(status.teams_count).to eq 0
    end

    it 'selects an active installation even when inactive records surround it' do
      Fabricate(:team, active: false)
      active = Fabricate(:team, active: true)
      Fabricate(:team, active: false)
      allow_any_instance_of(Team).to receive(:ping!) do |record|
        expect(record.id).to eq active.id
        { ok: 1 }
      end
      expect(client.status.ping['ok']).to eq 1
    end

    context 'with a team' do
      let!(:team) { Fabricate(:team, active: true) }
      it 'returns a status with ping' do
        status = client.status
        expect(status.teams_count).to eq 1
        ping = status.ping
        expect(ping['ok']).to eq 1
      end

      %w[account_inactive invalid_auth].each do |error|
        context "when Slack returns #{error}" do
          before do
            allow_any_instance_of(Team).to receive(:ping!).and_raise(Slack::Web::Api::Errors::SlackError, error)
          end

          it 'deactivates the installation and returns an explicit failed ping' do
            expect(SlackRubyBotServer::Service.instance).to receive(:deactivate!).with(instance_of(Team)).and_call_original
            get '/api/status'
            status = JSON.parse(last_response.body)
            expect(last_response.status).to eq 200
            expect(status['ping']).to eq('ok' => false, 'error' => error)
            expect(status['active_teams_count']).to eq 0
            expect(team.reload.active?).to be false
          end
        end
      end

      it 'does not hide unrelated Slack failures or deactivate the installation' do
        allow_any_instance_of(Team).to receive(:ping!).and_raise(Slack::Web::Api::Errors::SlackError, 'ratelimited')
        get '/api/status'
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'ratelimited'
        expect(team.reload.active?).to be true
      end
    end

    context 'with only inactive teams' do
      before { Fabricate(:team, active: false) }

      it 'does not ping revoked credentials' do
        expect_any_instance_of(Team).not_to receive(:ping!)
        get '/api/status'
        status = JSON.parse(last_response.body)
        expect(last_response.status).to eq 200
        expect(status['ping']).to be_nil
        expect(status['teams_count']).to eq 1
        expect(status['active_teams_count']).to eq 0
      end
    end
  end
end
