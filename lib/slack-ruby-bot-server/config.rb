module SlackRubyBotServer
  module Config
    extend self

    attr_accessor :server_class
    attr_accessor :database_adapter

    def reset!
      self.server_class = SlackRubyBotServer::Server
    end

    def database_adapter
      database_adapter = if defined?(::Mongoid)
                           :mongo
                         elsif defined?(::Postgresql)
                           :postgresql
                         else
                           nil
                         end
    end

    def postgresql?
      database_adapter == :postgresql
    end

    def mongo?
      database_adapter == :mongo
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
