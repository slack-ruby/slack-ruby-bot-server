require 'spec_helper'

describe SlackRubyBot::Commands::Base do
  let(:client) { SlackRubyBot::Client.new }
  let(:message_hook) { SlackRubyBot::Hooks::Message.new }

  context 'exception handling' do
    context 'StandardError' do
      before do
        allow(SlackRubyBot::Commands::Base).to receive(:_invoke).and_raise('mock error')
      end

      it 'responds to channel with exception message' do
        expect(client).to receive(:say).with(channel: 'channel', text: 'mock error')
        message_hook.call(client, Hashie::Mash.new(text: 'raising exception', channel: 'channel', user: 'user'))
      end
    end

    context 'Mongoid::Errors::Validations' do
      class MockDocument
        include Mongoid::Document
        validates_presence_of :mock_id
      end
      let(:mock_document) { MockDocument.new }

      before do
        allow(SlackRubyBot::Commands::Base).to receive(:_invoke) { mock_document.save! }
      end

      it 'responds to channel with exception message' do
        expect(client).to receive(:say).with(channel: 'channel', text: "undefined method `mock_id' for #{mock_document.inspect}")
        message_hook.call(client, Hashie::Mash.new(text: 'raising exception', channel: 'channel', user: 'user'))
      end
    end
  end
end
