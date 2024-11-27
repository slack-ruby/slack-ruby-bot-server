# frozen_string_literal: true

require 'spec_helper'

describe SlackRubyBotServer::App do
  subject do
    SlackRubyBotServer::App.instance
  end
  context 'instance' do
    let(:app) { Class.new(SlackRubyBotServer::App) }
    it 'can be subclassed' do
      expect(app.instance).to be_a_kind_of(SlackRubyBotServer::App)
      expect(app.instance).to be_an_instance_of(app)
    end
  end
  context '#prepare!' do
    context 'when connection cannot be established' do
      context 'with ActiveRecord >= 7.2' do
        before do
          skip 'incorrect ActiveRecord version' if ActiveRecord.version < Gem::Version.new('7.2')

          # Make sure ActiveRecord is not connected in any way before the spec starts
          ActiveRecord::Base.connection_pool.disconnect!
        end

        it 'raises' do
          expect(ActiveRecord::Base).not_to be_connected

          # Simulate that #database_exists? does not connect to the database
          allow(ActiveRecord::Base).to receive_message_chain(:connection, :database_exists?)
          expect { subject.prepare! }
            .to raise_error('Unexpected error.')
        end
      end

      context 'with ActiveRecord < 7.2' do
        before do
          skip 'incorrect ActiveRecord version' if ActiveRecord.version >= Gem::Version.new('7.2')
        end

        it 'raises' do
          # In ActiveRecord < 7.1, `disconnect!` closes the connection that has already been leased by
          #   DatabaseCleaner, so we cannot do that trick here to simulate a not established connection.
          allow(ActiveRecord::Base).to receive(:connected?).and_return(false)
          expect { subject.prepare! }
            .to raise_error('Unexpected error.')
        end
      end
    end
  end
  context '#purge_inactive_teams!' do
    it 'purges teams' do
      expect(Team).to receive(:purge!)
      subject.send(:purge_inactive_teams!)
    end
  end
end
