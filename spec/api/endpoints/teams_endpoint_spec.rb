require 'spec_helper'

describe Api::Endpoints::TeamsEndpoint do
  include Api::Test::EndpointTest

  it_behaves_like 'a cursor api', Team

  context 'team' do
    let(:existing_team) { Fabricate(:team) }

    it 'returns a team' do
      team = client.team(id: existing_team.id)
      expect(team.id).to eq existing_team.id.to_s
      expect(team._links.self._url).to eq "http://example.org/api/teams/#{existing_team.id}"
    end

    it 'creates a team' do
      expect {
        team = client.teams._post(team: { token: 'token' })
        expect(team.id).to_not be_blank
        expect(team.token).to eq 'token'
      }.to change(Team, :count).by(1)
    end

    it 'updates a team' do
      team = client.team(id: existing_team.id.to_s)._put(team: { token: 'updated' })
      expect(team.token).to eq 'updated'
    end

    it 'deletes a team' do
      team = client.team(id: existing_team.id.to_s)
      expect {
        team._delete
        expect(team.id).to eq existing_team.id.to_s
      }.to change(Team, :count).by(-1)
    end
  end

  context 'teams' do
    3.times { Fabricate(:team) }
    it 'returns teams' do
      teams = client.teams
      expect(teams.map(&:id).sort).to eq Team.all.map(&:id).map(&:to_s).sort
    end
  end
end
