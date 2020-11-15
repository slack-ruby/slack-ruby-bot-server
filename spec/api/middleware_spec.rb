require 'spec_helper'

describe SlackRubyBotServer::Api::Middleware do
  def middleware_classes(app)
    r = [app]

    while (next_app = r.last.instance_variable_get(:@app))
      r << next_app
    end

    r
  end

  context 'overriding view_paths' do
    before do
      SlackRubyBotServer::Api::Middleware.reset!
      SlackRubyBotServer.configure do |config|
        config.view_paths << 'custom'
      end
    end
    it 'uses custom view paths' do
      server_pages = middleware_classes(SlackRubyBotServer::Api::Middleware.instance)[-2]
      expect(server_pages).to be_a Rack::ServerPages
      config = server_pages.instance_variable_get(:@config)
      expect(config[:view_path].count).to eq 4
      expect(config[:view_path][-1]).to eq 'custom'
    end
  end
end
