require 'spec_helper'

def app
  SlackRubyBotServer::Api::Middleware.instance
end

describe 'API' do
  include Rack::Test::Methods

  it 'root' do
    get '/api'
    expect(last_response.status).to eq 200
    links = JSON.parse(last_response.body)['_links']
    expect(links.keys.sort).to eq(%w[self status team teams].sort)
  end
end
