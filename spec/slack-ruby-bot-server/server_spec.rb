require 'spec_helper'

describe SlackRubyBotServer::Server do
  let(:logger) { subject.send :logger }
  let(:team) { Team.new(token: 'token') }
  context 'with options' do
    subject do
      SlackRubyBotServer::Server.new(
        team: team,
        send_gifs: false,
        aliases: %w(foo bar)
      )
    end
    before do
      allow(subject).to receive(:sleep)
      allow(logger).to receive(:error)
    end
    it 'sets GIFs' do
      expect(subject.send(:client).send_gifs?).to be false
    end
    it 'sets token' do
      expect(subject.send(:client).token).to eq 'token'
    end
    it 'sets aliases' do
      expect(subject.send(:client).aliases).to eq %w(foo bar)
      expect(subject.send(:client).names).to include 'foo'
    end
  end
end
