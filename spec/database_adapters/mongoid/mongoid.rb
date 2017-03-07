Mongo::Logger.logger.level = Logger::INFO
Mongoid.load!(File.expand_path('../../../sample_apps/sample_app_mongoid/config/mongoid.yml', __dir__), ENV['RACK_ENV'])
