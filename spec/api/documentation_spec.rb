require 'spec_helper'

describe SlackBotServer::API do
  include Rack::Test::Methods

  def app
    SlackBotServer::API
  end

  context 'swagger documentation root' do
    before do
      get '/api/swagger_doc'
      expect(last_response.status).to eq(200)
      @json = JSON.parse(last_response.body)
    end

    it 'exposes api version' do
      expect(@json['apiVersion']).to eq('v1')
      expect(@json['apis'].size).to be > 1
    end
  end

  context 'swagger documentation api' do
    before do
      get '/api/swagger_doc'
      expect(last_response.status).to eq(200)
      @apis = JSON.parse(last_response.body)['apis']
    end
  end
end
