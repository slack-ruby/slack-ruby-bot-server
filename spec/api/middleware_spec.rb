require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe SlackRubyBotServer::Api::Middleware do
  before { described_class.reset! }

  after { described_class.reset! }

  def middleware_classes(app)
    r = [app]

    while (next_app = r.last.instance_variable_get(:@app))
      r << next_app
    end

    r
  end

  context 'overriding view_paths' do
    before do
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

  context 'configuring server pages' do
    let(:directory) { Dir.mktmpdir('bot-server-pages') }
    let(:request) { Rack::MockRequest.new(described_class.instance) }

    before do
      File.write(File.join(directory, 'index.html.erb'), '<%= "Rendered" %>')
      SlackRubyBotServer.config.view_paths = [directory]
    end

    after { FileUtils.remove_entry(directory) }

    it 'preserves default template caching when no block is configured' do
      response = request.get('/')
      expect(response.body).to eq 'Rendered'
      expect(response['Cache-Control']).to be_nil
    end

    it 'applies the block after the default view paths and only when building the stack' do
      calls = []
      SlackRubyBotServer.configure do |config|
        config.server_pages do |pages|
          calls << pages.view_path
          pages.cache_control = 'private, no-cache'
        end
      end
      expect(request.get('/')['Cache-Control']).to eq 'private, no-cache'
      request.get('/')
      expect(calls).to eq [[directory]]
    end

    it 'allows the block to override the framework view paths' do
      SlackRubyBotServer.config.view_paths = []
      path = directory
      SlackRubyBotServer.config.server_pages { |pages| pages.view_path = path }
      expect(request.get('/').body).to eq 'Rendered'
    end

    it 'replaces a previously registered block' do
      SlackRubyBotServer.config.server_pages { |pages| pages.cache_control = 'public' }
      SlackRubyBotServer.config.server_pages { |pages| pages.cache_control = 'private, no-store' }
      expect(request.get('/')['Cache-Control']).to eq 'private, no-store'
    end

    it 'clears the block when configuration is reset' do
      SlackRubyBotServer.config.server_pages { |pages| pages.cache_control = 'private, no-store' }
      SlackRubyBotServer.config.reset!
      SlackRubyBotServer.config.view_paths = [directory]
      expect(request.get('/')['Cache-Control']).to be_nil
    end

    it 'does not hide configuration errors' do
      SlackRubyBotServer.config.server_pages { raise ArgumentError, 'Invalid page configuration' }
      expect { described_class.instance }.to raise_error ArgumentError, 'Invalid page configuration'
    end
  end
end
