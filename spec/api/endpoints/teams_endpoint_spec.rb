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
  end

  context 'teams' do
    3.times { Fabricate(:team) }
    it 'returns teams' do
      teams = client.teams
      expect(teams.map(&:id).sort).to eq Team.all.map(&:id).map(&:to_s).sort
    end
  end
end
