require 'spec_helper'

describe Api::Endpoints::TeamsEndpoint do
  include Api::Test::EndpointTest

  context 'cursor' do
    before do
      allow(Team).to receive(:where).with(token: nil).and_return(Team.all)
    end

    it_behaves_like 'a cursor api', Team
  end

  context 'team' do
    let(:existing_team) { Fabricate(:team) }

    it 'returns a team' do
      team = client(existing_team.token).team(id: existing_team.id)
      expect(team.id).to eq existing_team.id.to_s
      expect(team._links.self._url).to eq "http://example.org/api/teams/#{existing_team.id}"
    end

    it 'creates a team' do
      expect do
        team = client.teams._post(team: { token: 'token' })
        expect(team.id).to_not be_blank
        expect(team.token).to eq 'token'
      end.to change(Team, :count).by(1)
    end

    it 'updates a team' do
      team = client(existing_team.token).team(id: existing_team.id.to_s)._put(team: { token: 'updated' })
      expect(team.token).to eq 'updated'
    end

    it 'deletes a team' do
      team = client(existing_team.token).team(id: existing_team.id.to_s)
      expect do
        team._delete
        expect(team.id).to eq existing_team.id.to_s
      end.to change(Team, :count).by(-1)
    end

    context 'requires token to' do
      it 'retrieve' do
        expect { client.team(id: existing_team.id).id }.to raise_error Faraday::ResourceNotFound
      end

      it 'update' do
        expect { client.team(id: existing_team.id.to_s)._put(team: {}) }.to raise_error Faraday::ResourceNotFound
      end

      it 'delete' do
        expect { client.team(id: existing_team.id.to_s)._delete }.to raise_error Faraday::ResourceNotFound
      end
    end
  end
end
