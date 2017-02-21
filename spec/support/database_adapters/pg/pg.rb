require 'active_record'

environment = ENV['RACK_ENV'] || 'development'
db_config   = YAML.load(File.read(File.expand_path('../sample_app/config/postgresql.yml', __FILE__)))
ActiveRecord::Base.establish_connection db_config[environment]
