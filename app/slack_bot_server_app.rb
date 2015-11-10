module SlackBotServer
  class App
    def initialize
      @filenames = ['', '.html', 'index.html', '/index.html']

      @rack_static = ::Rack::Static.new(
        lambda { [404, {}, []] },
        root: File.expand_path('../../public', __FILE__),
        urls: ['/']
      )

      check_database!
    end

    def self.instance
      @instance ||= Rack::Builder.new do
        use Rack::Cors do
          allow do
            origins '*'
            resource '*', headers: :any, methods: :get
          end
        end

        run SlackBotServer::App.new
      end.to_app
    end

    def call(env)
      # api
      response = Api::Endpoints::RootEndpoint.call(env)

      # Check if the App wants us to pass the response along to others
      if response[1]['X-Cascade'] == 'pass'
        # static files
        request_path = env['PATH_INFO']
        @filenames.each do |path|
          response = @rack_static.call(env.merge('PATH_INFO' => request_path + path))
          return response if response[0] != 404
        end
      end

      # Serve error pages or respond with API response
      case response[0]
      when 404, 500
        content = @rack_static.call(env.merge('PATH_INFO' => "/errors/#{response[0]}.html"))
        [response[0], content[1], content[2]]
      else
        response
      end
    end

    def check_database!
      rc = Mongoid.default_client.command(ping: 1)
      return if rc && rc.ok?
      fail rc.documents.first['error'] || 'Unexpected error.'
    rescue Exception => e
      warn "Error connecting to MongoDB: #{e.message}"
      raise e
    end
  end
end
