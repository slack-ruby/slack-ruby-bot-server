require 'spec_helper'

describe 'Teams', js: true, type: :feature do
  before do
    ENV['SLACK_CLIENT_ID'] = 'client_id'
    ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
    SlackRubyBotServer::Config.oauth_scope = ['channels:read', 'channels:write']
    allow_any_instance_of(Team).to receive(:ping!).and_return(ok: true)
  end
  after do
    ENV.delete 'SLACK_CLIENT_ID'
    ENV.delete 'SLACK_CLIENT_SECRET'
    SlackRubyBotServer::Config.oauth_scope = nil
  end
  context 'oauth v1' do
    before do
      SlackRubyBotServer::Config.oauth_version = :v1
    end
    context 'oauth' do
      before do
        oauth_access = Slack::Messages::Message.new({ 'bot' => { 'bot_access_token' => 'token' }, 'team_id' => 'team_id', 'team_name' => 'team_name' })
        allow_any_instance_of(Slack::Web::Client).to receive(:oauth_access).with(hash_including(code: 'code')).and_return(oauth_access)
      end
      it 'registers a team' do
        expect do
          visit '/?v1&code=code'
          expect(page.find('#messages')).to have_content 'Team successfully registered!'
        end.to change(Team, :count).by(1)
      end
      it 'includes optional parameter' do
        expect(SlackRubyBotServer::Service.instance).to receive(:create!).with(instance_of(Team), { state: 'property' })
        visit '/?v1&code=code&state=property'
      end
    end
    context 'homepage' do
      before do
        visit '/?v1'
      end
      it 'includes a link to add to slack with the client id' do
        expect(title).to eq('Slack Ruby Bot Server')
        expect(find("a[href='https://slack.com/oauth/authorize?scope=channels:read+channels:write&client_id=client_id"))
      end
    end
  end
  context 'oauth v2' do
    before do
      SlackRubyBotServer::Config.oauth_version = :v2
    end
    context 'oauth' do
      before do
        oauth_access = Slack::Messages::Message.new({ 'access_token' => 'token', 'team' => { 'id' => 'team_id', 'name' => 'team_name' } })
        allow_any_instance_of(Slack::Web::Client).to receive(:oauth_v2_access).with(hash_including(code: 'code')).and_return(oauth_access)
      end
      it 'registers a team' do
        expect do
          visit '/?v2&code=code'
          expect(page.find('#messages')).to have_content 'Team successfully registered!'
        end.to change(Team, :count).by(1)
      end
      it 'includes optional parameter' do
        expect(SlackRubyBotServer::Service.instance).to receive(:create!).with(instance_of(Team), { state: 'property' })
        visit '/?v2&code=code&state=property'
      end
    end
    context 'homepage' do
      before do
        visit '/?v2'
      end
      it 'includes a link to add to slack with the client id' do
        expect(title).to eq('Slack Ruby Bot Server')
        expect(find("a[href='https://slack.com/oauth/v2/authorize?scope=channels:read+channels:write&client_id=client_id"))
      end
    end
  end
end
