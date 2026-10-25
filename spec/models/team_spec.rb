require 'spec_helper'

describe Team do
  context 'workspace metadata' do
    let(:team) { Fabricate(:team, name: 'Old name', domain: 'old-domain') }
    let(:auth) do
      Slack::Messages::Message.new(
        'ok' => true,
        'team_id' => team.team_id,
        'team' => 'New workspace name',
        'url' => 'https://new-domain.slack.com/',
        'user_id' => 'UBOT'
      )
    end
    let(:slack_client) { instance_double(Slack::Web::Client) }
    let(:presence) { { 'presence' => 'active' } }

    before do
      allow(Slack::Web::Client).to receive(:new).with(token: team.token).and_return(slack_client)
      allow(slack_client).to receive(:auth_test).and_return(auth)
      allow(slack_client).to receive(:users_getPresence).with(user: 'UBOT').and_return(presence)
    end

    it 'persists current workspace info from a ping without an extra API request' do
      expect(slack_client).to receive(:auth_test).once.and_return(auth)
      expect(team.ping!).to eq(auth: auth, presence: presence)
      expect(team.reload.name).to eq 'New workspace name'
      expect(team.domain).to eq 'new-domain'
    end

    it 'can refresh workspace info without fetching presence' do
      expect(slack_client).not_to receive(:users_getPresence)
      expect(team.update_info!).to eq auth
      expect(team.reload.name).to eq 'New workspace name'
      expect(team.domain).to eq 'new-domain'
    end

    it 'does not write an unchanged workspace' do
      team.update!(name: 'New workspace name', domain: 'new-domain')
      expect(team).not_to receive(:update!)
      team.ping!
    end

    it 'refreshes info even when presence requires an additional scope' do
      allow(slack_client).to receive(:users_getPresence).and_raise(Slack::Web::Api::Errors::MissingScope, 'missing_scope')
      expect(team.ping!).to eq(auth: auth, presence: nil)
      expect(team.reload.domain).to eq 'new-domain'
    end

    it 'does not change stored info when Slack authentication fails' do
      allow(slack_client).to receive(:auth_test).and_raise(Slack::Web::Api::Errors::SlackError, 'invalid_auth')
      expect { team.ping! }.to raise_error(Slack::Web::Api::Errors::SlackError, 'invalid_auth')
      expect(team.reload.name).to eq 'Old name'
      expect(team.domain).to eq 'old-domain'
    end

    it 'rejects a response for another workspace without changing stored info' do
      expect do
        team.update_info!(auth.merge('team_id' => 'TOTHER'))
      end.to raise_error(ArgumentError, 'Slack authentication belongs to a different workspace.')
      expect(team.reload.name).to eq 'Old name'
      expect(team.domain).to eq 'old-domain'
    end

    it 'rejects malformed workspace URLs without partially updating the name' do
      expect do
        team.update_info!(auth.merge('url' => '/not-a-workspace'))
      end.to raise_error(ArgumentError, 'Slack authentication returned an invalid workspace URL.')
      expect(team.reload.name).to eq 'Old name'
      expect(team.domain).to eq 'old-domain'
    end
  end

  context '#purge!' do
    let!(:active_team) { Fabricate(:team) }
    let!(:inactive_team) { Fabricate(:team, active: false) }
    let!(:inactive_team_a_week_ago) { Fabricate(:team, updated_at: 1.week.ago, active: false) }
    let!(:inactive_team_two_weeks_ago) { Fabricate(:team, updated_at: 2.weeks.ago, active: false) }
    let!(:inactive_team_a_month_ago) { Fabricate(:team, updated_at: 1.month.ago, active: false) }
    it 'destroys teams inactive for two weeks' do
      expect do
        Team.purge!
      end.to change(Team, :count).by(-2)
      expect(Team.where(id: active_team.id).first).to eq active_team
      expect(Team.where(id: inactive_team.id).first).to eq inactive_team
      expect(Team.where(id: inactive_team_a_week_ago.id).first).to eq inactive_team_a_week_ago
      expect(Team.where(id: inactive_team_two_weeks_ago.id).first).to be nil
      expect(Team.where(id: inactive_team_a_month_ago.id).first).to be nil
    end
    it 'does not raise errors when a team cannot be destroyed' do
      allow_any_instance_of(Team).to receive(:destroy).and_raise(StandardError, 'cannot be destroyed')
      expect do
        expect do
          Team.purge!
        end.to_not change(Team, :count)
      end.to_not raise_error
    end
  end
end
