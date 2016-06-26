module SlackRubyBotServer
  module Config
    extend self

    attr_accessor :server_class

    def reset!
      self.server_class = SlackRubyBotServer::Server
    end

    reset!
  end

  class << self
    def configure
      block_given? ? yield(Config) : Config
    end

    def config
      Config
    end
  end
end
