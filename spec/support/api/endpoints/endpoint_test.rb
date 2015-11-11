module Api
  module Test
    module EndpointTest
      extend ActiveSupport::Concern
      include Rack::Test::Methods

      included do
        def client(token = nil)
          Hyperclient.new('http://example.org/api') do |client|
            client.headers = {
              'Content-Type' => 'application/json',
              'Accept' => 'application/json,application/hal+json',
              'Token' => token
            }
            client.connection(default: false) do |conn|
              conn.request :json
              conn.response :json
              conn.use Faraday::Response::RaiseError
              conn.use FaradayMiddleware::FollowRedirects
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
