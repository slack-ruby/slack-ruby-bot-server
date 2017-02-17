require 'active_record'

environment = ENV['RACK_ENV'] || 'development'
db_config   = YAML.load(File.read(File.expand_path('../../database.yml', __FILE__)))
ActiveRecord::Base.establish_connection db_config[environment]

load File.dirname(__FILE__) + '/schema.rb'
