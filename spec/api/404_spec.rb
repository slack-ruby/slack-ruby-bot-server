require 'spec_helper'

describe SlackRubyBotServer::Api do
  include SlackRubyBotServer::Api::Test::EndpointTest

  context '404' do
    it 'returns a plain 404' do
      get '/foobar'
      expect(last_response.status).to eq 404
      expect(last_response.body).to eq '404 Not Found'
    end
  end
end
