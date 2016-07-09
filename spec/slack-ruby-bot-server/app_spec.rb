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
  context '#purge_inactive_teams!' do
    it 'purges teams' do
      expect(Team).to receive(:purge!)
      subject.send(:purge_inactive_teams!)
    end
  end
end
