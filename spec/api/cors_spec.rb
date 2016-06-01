require 'spec_helper'

describe SlackRubyBotServer::Api do
  include SlackRubyBotServer::Api::Test::EndpointTest

  context 'CORS' do
    it 'supports options' do
      options '/api', {},
              'HTTP_ORIGIN' => 'http://cors.example.com',
              'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'Origin, Accept, Content-Type',
              'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'

      expect(last_response.status).to eq 200
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq 'http://cors.example.com'
      expect(last_response.headers['Access-Control-Expose-Headers']).to eq ''
    end
    it 'includes Access-Control-Allow-Origin in the response' do
      get '/api', {}, 'HTTP_ORIGIN' => 'http://cors.example.com'
      expect(last_response.status).to eq 200
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq 'http://cors.example.com'
    end
    it 'includes Access-Control-Allow-Origin in errors' do
      get '/api/invalid', {}, 'HTTP_ORIGIN' => 'http://cors.example.com'
      expect(last_response.status).to eq 404
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq 'http://cors.example.com'
    end
  end
end
