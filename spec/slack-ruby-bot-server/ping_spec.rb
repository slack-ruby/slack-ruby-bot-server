require 'spec_helper'

describe SlackRubyBotServer::Ping do
  let(:team) { Team.new(token: 'token') }
  let(:server) { SlackRubyBotServer::Server.new(team: team) }
  let(:client) { server.send(:client) }
  let(:options) { {} }

  subject do
    SlackRubyBotServer::Ping.new(client, options)
  end

  context 'with defaults' do
    before do
      allow(subject.wrapped_object).to receive(:every).and_yield
    end

    it 'defaults retry count' do
      expect(subject.send(:retry_count)).to eq 2
    end

    it 'calculates retries left' do
      expect(subject.send(:retries_left)).to eq 2
    end

    it 'defaults ping interval' do
      expect(subject.send(:ping_interval)).to eq 60
    end

    it 'checks for connection' do
      expect(subject.wrapped_object).to receive(:check!)
      subject.start!
    end

    context 'after a failed check' do
      before do
        allow(subject.wrapped_object).to receive(:online?).and_return(false)
        subject.start!
      end

      it 'decrements retries left' do
        expect(subject.send(:retries_left)).to eq 1
      end

      it 'sets error count' do
        expect(subject.send(:error_count)).to eq 1
      end

      context 'after a successful check' do
        before do
          allow(subject.wrapped_object).to receive(:online?).and_return(true)
          subject.start!
        end

        it 're-increments retries left' do
          expect(subject.send(:retries_left)).to eq 2
        end

        it 'resets error count' do
          expect(subject.send(:error_count)).to eq 0
        end
      end
    end

    it 'terminates the ping worker after account_inactive' do
      allow(subject.wrapped_object).to receive(:online?).and_raise('account_inactive')
      expect(subject.wrapped_object).to receive(:terminate)
      subject.start!
    end

    it 'terminates after a number of retries' do
      allow(subject.wrapped_object).to receive(:online?).and_return(false)
      expect(subject.wrapped_object).to receive(:terminate)
      3.times { subject.start! }
    end
  end

  context 'with options' do
    context 'ping interval' do
      let(:options) { { ping_interval: 42 } }

      it 'is used' do
        expect(subject.send(:ping_interval)).to eq 42
        expect(subject.wrapped_object).to receive(:every).with(42)
        subject.start!
      end
    end

    context 'retry count' do
      let(:options) { { retry_count: 42 } }

      it 'is set' do
        expect(subject.send(:retry_count)).to eq 42
      end

      it 'adjusts retries left' do
        expect(subject.send(:retries_left)).to eq 42
      end
    end
  end
end
