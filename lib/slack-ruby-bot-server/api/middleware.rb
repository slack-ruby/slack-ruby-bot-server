%w(rack/cors rack-rewrite rack-server-pages).each { |l| require l }

module SlackRubyBotServer
  module Api
    class Middleware
      def self.logger
        @logger ||= begin
          $stdout.sync = true
          Logger.new(STDOUT)
        end
      end

      def self.instance
        @instance ||= Rack::Builder.new do
          use Rack::Cors do
            allow do
              origins '*'
              resource '*', headers: :any, methods: [:get, :post]
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
