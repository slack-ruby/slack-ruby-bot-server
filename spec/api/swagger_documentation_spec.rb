require 'spec_helper'

describe SlackRubyBotServer::Api do
  include SlackRubyBotServer::Api::Test::EndpointTest

  context 'swagger root' do
    subject do
      get '/api/swagger_doc'
      JSON.parse(last_response.body)
    end
    it 'documents root level apis' do
      expect(subject['apis'].map { |api| api['path'] }).to eq([
        '/status.{format}',
        '/teams.{format}',
        '/swagger_doc.{format}'
      ])
    end
  end

  context 'teams' do
    subject do
      get '/api/swagger_doc/teams'
      JSON.parse(last_response.body)
    end
    it 'documents teams apis' do
      expect(subject['apis'].map { |api| api['path'] }).to eq([
        '/api/teams/{id}.{format}',
        '/api/teams.{format}'
      ])
    end
  end
end
