require 'spec_helper'

describe Team do
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
