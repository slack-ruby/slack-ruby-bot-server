require 'spec_helper'
require 'commands/whoami'

describe Whoami do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackRubyBotServer::Server.new(team: team) }
  context 'whoami' do
    it 'returns username' do
      expect(message: "#{SlackRubyBot.config.user} whoami", channel: 'channel', user: 'user').to respond_with_slack_message(
        '<@user>'
      )
    end
  end
end
