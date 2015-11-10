module Api
  module Test
    module EndpointTest
      extend ActiveSupport::Concern
      include Rack::Test::Methods

      included do
        let(:client) do
          Hyperclient.new('http://example.org/api') do |client|
            client.connection(default: false) do |conn|
              conn.request :json
              conn.response :json
              conn.use Faraday::Adapter::Rack, app
            end
          end
        end
      end

      def app
        SlackBotServer::App.instance
      end
    end
  end
end
