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
      it 'assigns team server' do
        expect(team.server).to_not be nil
      end
      it 'removes team server' do
        SlackRubyBotServer::Service.instance.stop!(team)
        expect(team.server).to be nil
      end
      it 'deactivates a team' do
        SlackRubyBotServer::Service.instance.deactivate!(team)
        expect(team.server).to be nil
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
    let(:instance) { SlackRubyBotServer::Service.instance }
    context 'single' do
      before do
        @events = []
        [:starting].each do |event|
          instance.on event do |team, _e|
            expect(team).to_not be_nil
            expect(team.server).to be_nil
            @events << event.to_s
          end
        end
        %i[started stopping stopped].each do |event|
          instance.on event do |team, _e|
            expect(team).to_not be_nil
            expect(team.server).to_not be_nil
            @events << event.to_s
          end
        end
      end
      it 'invokes start and stop callbacks' do
        allow_any_instance_of(SlackRubyBotServer::Server).to receive(:start_async)
        instance.start!(team)
        allow_any_instance_of(SlackRubyBotServer::Server).to receive(:stop!)
        instance.stop!(team)
        expect(@events).to eq %w[starting started stopping stopped]
      end
    end
    context 'multiple callbacks' do
      before do
        @events = []
        instance.on :starting, :stopping do |team|
          expect(team).to_not be_nil
          @events << 'call'
        end
      end
      it 'invokes starting and stopping callbacks' do
        allow_any_instance_of(SlackRubyBotServer::Server).to receive(:start_async)
        instance.start!(team)
        allow_any_instance_of(SlackRubyBotServer::Server).to receive(:stop!)
        instance.stop!(team)
        expect(@events).to eq %w[call call]
      end
    end
    context 'multiple callback blocks' do
      before do
        @events = []
        instance.on :starting, :starting do |team|
          expect(team).to_not be_nil
          @events << 'starting'
        end
      end
      it 'invokes starting and stopping callbacks' do
        allow_any_instance_of(SlackRubyBotServer::Server).to receive(:start_async)
        instance.start!(team)
        allow_any_instance_of(SlackRubyBotServer::Server).to receive(:stop!)
        instance.stop!(team)
        expect(@events).to eq %w[starting starting]
      end
    end
  end
  context 'timers' do
    let(:instance) { SlackRubyBotServer::Service.instance }
    context 'without timers' do
      it 'noop' do
        Async::Reactor.run do |task|
          instance.start_intervals!
          task.stop
        end
        expect(instance.instance_variable_get(:@intervals).keys).to eq []
      end
    end
    context 'invalid interval' do
      it 'string' do
        expect { instance.every 'invalid' }.to raise_error 'Invalid interval "invalid".'
      end
      it 'symbol' do
        expect { instance.every :invalid }.to raise_error 'Invalid interval "invalid".'
      end
      it 'zero' do
        expect { instance.every 0 }.to raise_error 'Invalid interval "0".'
      end
      it 'negative' do
        expect { instance.every -1 }.to raise_error 'Invalid interval "-1".'
      end
    end
    context 'with timers' do
      before do
        @events = []
        instance.every :hour, :day do
          @events << '1h, 1d'
        end
        instance.every 1, 2 do
          @events << '1-2s'
        end
        instance.every :minute do
          @events << '1m'
        end
        instance.every 1 do
          @events << '1s'
        end
      end
      it 'sets up timers' do
        Async::Reactor.run do |task|
          instance.start_intervals!
          task.sleep 3
          task.stop
        end
        expect(instance.instance_variable_get(:@intervals).keys).to eq [3600, 86_400, 1, 2, 60]
        expect(@events.sort.uniq).to eq %w[1-2s 1s]
      end
    end
  end
  context 'overriding service_class' do
    let(:service_class) do
      Class.new(SlackRubyBotServer::Service) do
        def url
          'https://www.example.com'
        end
      end
    end
    after do
      SlackRubyBotServer.config.reset!
    end
    it 'creates an instance of service class' do
      SlackRubyBotServer.configure do |config|
        config.service_class = service_class
      end
      expect(SlackRubyBotServer::Service.instance).to be_a service_class
      expect(SlackRubyBotServer::Service.instance.url).to eq 'https://www.example.com'
    end
  end
end
