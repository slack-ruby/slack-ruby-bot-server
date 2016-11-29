module SlackRubyBotServer
  module Config
    extend self

    attr_accessor :server_class
    attr_accessor :database

    def reset!
      self.server_class = SlackRubyBotServer::Server
    end

    def database
      database ||= File.file?('config/mongoid.yml') ? :mongo : :postgresql
    end

    def postgresql?
      database == :postgresql
    end

    def mongo?
      database == :mongo
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
