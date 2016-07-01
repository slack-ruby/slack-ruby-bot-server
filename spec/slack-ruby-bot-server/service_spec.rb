require 'spec_helper'

describe SlackRubyBotServer::Service do
  let(:team) { Fabricate(:team) }
  after do
    SlackRubyBotServer::Service.reset!
  end
  context 'with defaults' do
    let(:server) { SlackRubyBotServer::Server.new(team: team) }
    let(:services) { SlackRubyBotServer::Service.instance.instance_variable_get(:@services) }
    before do
      allow(SlackRubyBotServer::Server).to receive(:new).with(team: team).and_return(server)
      allow(server).to receive(:stop!)
    end
    it 'starts a team' do
      expect(server).to receive(:start_async)
      SlackRubyBotServer::Service.instance.start!(team)
    end
    context 'started team' do
      before do
        allow(server).to receive(:start_async)
        SlackRubyBotServer::Service.instance.start!(team)
      end
      it 'registers team service' do
        expect(services.size).to eq 1
        expect(services[team.token]).to eq server
      end
      it 'removes team service' do
        SlackRubyBotServer::Service.instance.stop!(team)
        expect(services.size).to eq 0
      end
      it 'deactivates a team' do
        SlackRubyBotServer::Service.instance.deactivate!(team)
        expect(team.reload.active).to be false
        expect(services.size).to eq 0
      end
    end
  end
  context 'overriding server_class' do
    let(:server_class) do
      Class.new(SlackRubyBotServer::Server) do
        attr_reader :called

        def initialize(options = {})
          @called = true
          super
        end
      end
    end
    after do
      SlackRubyBotServer.config.reset!
    end
    it 'creates an instance of server class' do
      expect(server_class).to receive(:new).with(team: team).and_call_original
      allow_any_instance_of(server_class).to receive(:start_async)
      allow_any_instance_of(server_class).to receive(:stop!)
      SlackRubyBotServer.configure do |config|
        config.server_class = server_class
      end
      SlackRubyBotServer::Service.instance.start!(team)
      SlackRubyBotServer::Service.instance.stop!(team)
    end
  end
  context 'callbacks' do
    before do
      @events = []
      SlackRubyBotServer::Service.instance.tap do |instance|
        [:starting].each do |event|
          instance.on event do |team, server, _e|
            expect(team).to_not be_nil
            expect(server).to be_nil
            @events << event.to_s
          end
        end
        [:started, :stopping, :stopped].each do |event|
          instance.on event do |team, server, _e|
            expect(team).to_not be_nil
            expect(server).to_not be_nil
            @events << event.to_s
          end
        end
      end
    end
    it 'invokes start and stop callbacks' do
      allow_any_instance_of(SlackRubyBotServer::Server).to receive(:start_async)
      SlackRubyBotServer::Service.instance.start!(team)
      allow_any_instance_of(SlackRubyBotServer::Server).to receive(:stop!)
      SlackRubyBotServer::Service.instance.stop!(team)
      expect(@events).to eq %w(starting started stopping stopped)
    end
  end
end
