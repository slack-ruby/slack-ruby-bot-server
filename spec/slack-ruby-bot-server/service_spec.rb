require 'spec_helper'

describe SlackRubyBotServer::Service do
  let(:team) { Fabricate(:team) }
  after do
    SlackRubyBotServer::Service.reset!
  end
  context 'callbacks' do
    let(:instance) { SlackRubyBotServer::Service.instance }
    context 'single' do
      before do
        @events = []
        %i[starting started stopping stopped].each do |event|
          instance.on event do |team, _e|
            expect(team).to_not be_nil
            @events << event.to_s
          end
        end
      end
      it 'invokes start and stop callbacks' do
        instance.start!(team)
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
        instance.start!(team)
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
        instance.start!(team)
        instance.stop!(team)
        expect(@events).to eq %w[starting starting]
      end
    end
  end
  context 'timers' do
    let(:instance) { SlackRubyBotServer::Service.instance }
    context 'without timers' do
      it 'noop' do
        instance.start_intervals!(&:stop)
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
        instance.start_intervals! do |task|
          task.sleep 3
          task.stop
        end
        expect(instance.instance_variable_get(:@intervals).keys).to eq [3600, 86_400, 1, 2, 60]
        expect(@events.sort.uniq).to eq %w[1-2s 1s]
      end
    end
    context 'with a failing timer' do
      before do
        @events = []
        instance.every 1 do
          @events << 'fail'
          raise 'error'
        end
        instance.every 1 do
          @events << '1'
        end
      end
      it 'does not abort all timers on failure of the first one' do
        instance.start_intervals! do |task|
          task.sleep 3
          task.stop
        end
        expect(@events.sort.uniq).to eq %w[1 fail]
      end
    end
    context 'once_and_every' do
      context '5 seconds' do
        before do
          @events = []
          instance.once_and_every 5 do
            @events << '1'
          end
        end
        it 'runs the timer once within 3 seconds' do
          instance.start_intervals! do |task|
            task.sleep 3
            task.stop
          end
          expect(@events).to eq %w[1]
        end
      end
      context '2 seconds' do
        before do
          @events = []
          instance.once_and_every 2 do
            @events << '1'
          end
        end
        it 'runs the timer exactly twice within 3 seconds' do
          instance.start_intervals! do |task|
            task.sleep 3
            task.stop
          end
          expect(@events).to eq %w[1 1]
        end
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
