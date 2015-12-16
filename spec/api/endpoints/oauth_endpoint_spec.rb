require 'spec_helper'

describe Api::Endpoints::OAuthEndpoint do
  include Api::Test::EndpointTest

  context 'oauth' do
    it 'creates a team' do
      expect(SlackRubyBot::Service).to receive(:start!).with('token')
      oauth_access = { 'bot' => { 'bot_access_token' => 'token' } }
      allow_any_instance_of(Slack::Web::Client).to receive(:oauth_access).with(hash_including(code: 'code')).and_return(oauth_access)
      expect do
        team = client.oauth._post(code: 'code')
        expect(team.id).to_not be_blank
        expect(team.token).to eq 'token'
      end.to change(Team, :count).by(1)
    end
  end
end
