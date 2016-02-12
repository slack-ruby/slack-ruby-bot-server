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
        use GC::OOB::UnicornMiddleware

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

        use Rack::Robotz, 'User-Agent' => '*', 'Disallow' => '/'

        use Rack::ServerPages

        run Api::Middleware.new
      end.to_app
    end

    def call(env)
      Api::Endpoints::RootEndpoint.call(env)
    end
  end
end
