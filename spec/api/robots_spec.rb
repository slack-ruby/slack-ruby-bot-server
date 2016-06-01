require 'spec_helper'

describe SlackRubyBotServer::Api do
  include SlackRubyBotServer::Api::Test::EndpointTest

  it 'returns a robots.txt that disallows indexing' do
    get '/robots.txt'
    expect(last_response.status).to eq 200
    expect(last_response.headers['Content-Type']).to eq 'text/plain'
    expect(last_response.body).to eq "User-Agent: *\nDisallow: /"
  end
end
