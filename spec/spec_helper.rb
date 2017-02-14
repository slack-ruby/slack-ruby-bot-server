ENV['RACK_ENV'] = 'test'

require 'hyperclient'
require 'webmock/rspec'
require 'slack-ruby-bot-server/rspec'

SlackRubyBotServer::Service.logger.level = Logger::WARN

files       = Dir[File.join(__dir__, 'support', '**/*.rb')]
mongo_files = ["#{File.dirname(__FILE__)}/support/mongoid.rb"]

if defined? Mongo
  # Setup for Mongo
  Mongo::Logger.logger.level = Logger::INFO
  Mongoid.load!(File.expand_path('../sample_app/config/mongoid.yml', __dir__), ENV['RACK_ENV'])
  files.each {|file| require file }
else
  # Set up for active record
  require 'active_record'
  environment = ENV['RACK_ENV'] || 'development'
  db_config   = YAML.load(File.read(File.expand_path('../../database.yml', __FILE__)))
  ActiveRecord::Base.establish_connection db_config[environment]

  # Require necessary files except mongo files
  files.each do |file|
    unless mongo_files.include? file
      require file
    end
  end

  load File.dirname(__FILE__) + '/schema.rb'
  require File.dirname(__FILE__) + '/models.rb'
end



