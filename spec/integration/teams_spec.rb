require 'spec_helper'

describe 'Teams', js: true, type: :feature do
  before do
    ENV['SLACK_CLIENT_ID'] = 'client_id'
    ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
  end
  after do
    ENV.delete 'SLACK_CLIENT_ID'
    ENV.delete 'SLACK_CLIENT_SECRET'
  end
  context 'oauth', vcr: { cassette_name: 'auth_test' } do
    it 'registers a team' do
      allow_any_instance_of(Team).to receive(:ping!).and_return(ok: true)
      expect(SlackRubyBotServer::Service.instance).to receive(:start!)
      oauth_access = { 'bot' => { 'bot_access_token' => 'token' }, 'team_id' => 'team_id', 'team_name' => 'team_name' }
      allow_any_instance_of(Slack::Web::Client).to receive(:oauth_access).with(hash_including(code: 'code')).and_return(oauth_access)
      expect do
        visit '/?code=code'
        expect(page.find('#messages')).to have_content 'Team successfully registered!'
      end.to change(Team, :count).by(1)
    end
  end
  context 'homepage' do
    before do
      visit '/'
    end
    it 'displays index.html page' do
      expect(title).to eq('Slack Ruby Bot Server')
    end
    it 'includes a link to add to slack with the client id' do
      expect(find("a[href='https://slack.com/oauth/authorize?scope=bot&client_id=#{ENV['SLACK_CLIENT_ID']}']"))
    end
  end
end
