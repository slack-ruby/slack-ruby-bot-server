$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

Bundler.require :default, ENV['RACK_ENV']

['config/initializers', 'api', 'app', 'models'].each do |path|
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', path))
  Dir[File.expand_path("../../#{path}/**/*.rb", __FILE__)].each do |f|
    require f
  end
end

Mongoid.load! File.expand_path('../mongoid.yml', __FILE__), ENV['RACK_ENV']

require 'slack_bot_server_app'
