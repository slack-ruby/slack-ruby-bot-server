Mongo::Logger.logger.level = Logger::INFO
Mongoid.load!(File.expand_path('../sample_app/config/mongoid.yml', __dir__), ENV['RACK_ENV'])
