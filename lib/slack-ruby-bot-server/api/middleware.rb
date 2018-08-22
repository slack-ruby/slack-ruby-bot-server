require 'rack/cors'
require 'rack-rewrite'
require 'rack-server-pages'
require 'otr-activerecord' if SlackRubyBotServer::Config.activerecord? && !defined?(::Rails)

module SlackRubyBotServer
  module Api
    class Middleware
      def self.logger
        @logger ||= begin
          STDOUT.sync = true
          Logger.new(STDOUT)
        end
      end

      def self.instance
        @instance ||= Rack::Builder.new do
          use OTR::ActiveRecord::ConnectionManagement if SlackRubyBotServer::Config.activerecord? && defined?(::OTR)

          use Rack::Cors do
            allow do
              origins '*'
              resource '*', headers: :any, methods: %i[get post]
            end
          end

          # rewrite HAL links to make them clickable in a browser
          use Rack::Rewrite do
            r302 %r{(\/[\w\/]*\/)(%7B|\{)?(.*)(%7D|\})}, '$1'
          end

          use Rack::ServerPages do |config|
            config.view_path = [
              'views', # relative to Dir.pwd
              'public', # relative to Dir.pwd
              File.expand_path(File.join(__dir__, '../../../public')) # built-in fallback
            ]
          end

          run Middleware.new
        end.to_app
      end

      def call(env)
        Endpoints::RootEndpoint.call(env)
      end
    end
  end
end
