module SlackRubyBotServer
  module Config
    extend self

    attr_accessor :server_class
    attr_accessor :database_adapter

    def reset!
      self.server_class = SlackRubyBotServer::Server
    end

    def database_adapter
      if defined?(::Mongoid)
        :mongoid
      elsif defined?(::Postgresql)
        :pg
      end
    end

    def pg?
      database_adapter == :pg
    end

    def mongoid?
      database_adapter == :mongoid
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
