require 'spec_helper'

describe SlackBotServer::API do
  include Rack::Test::Methods

  def app
    SlackBotServer::API
  end

  it 'ping' do
    get '/api/tokens'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq([].to_json)
  end
end
