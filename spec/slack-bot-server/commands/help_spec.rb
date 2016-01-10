require 'spec_helper'

describe SlackBotServer::Commands::Help do
  let!(:team) { Fabricate(:team) }
  let(:app) { SlackBotServer::Server.new(team: team) }
  let(:client) { app.send(:client) }
  it 'default' do
    expect(client).to receive(:say).with(channel: 'channel', text: [SlackBotServer::Commands::Help::HELP, SlackBotServer::INFO].join("\n"))
    expect(client).to receive(:say).with(channel: 'channel', gif: 'help')
    app.send(:message, client, channel: 'channel', text: "#{SlackRubyBot.config.user} help")
  end
end
