require 'spec_helper'

describe Team do
  context '#find_or_create_from_env!' do
    before do
      ENV['SLACK_API_TOKEN'] = 'token'
    end
    context 'team', vcr: { cassette_name: 'team_info' } do
      it 'creates a team' do
        expect { Team.find_or_create_from_env! }.to change(Team, :count).by(1)
        team = Team.first
        expect(team.team_id).to eq 'T04KB5WQH'
        expect(team.name).to eq 'dblock'
        expect(team.domain).to eq 'dblockdotorg'
        expect(team.token).to eq 'token'
      end
    end
    after do
      ENV.delete 'SLACK_API_TOKEN'
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
      expect(Team.find(active_team.id)).to eq active_team
      expect(Team.find(inactive_team.id)).to eq inactive_team
      expect(Team.find(inactive_team_a_week_ago.id)).to eq inactive_team_a_week_ago
      expect(Team.find(inactive_team_two_weeks_ago.id)).to be nil
      expect(Team.find(inactive_team_a_month_ago.id)).to be nil
    end
  end
end
