$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

Bundler.require :default, ENV['RACK_ENV']

['config/initializers', 'api', 'models', 'app'].each do |path|
  path = File.expand_path(File.join(File.dirname(__FILE__), '..', path))
  $LOAD_PATH.unshift path
  Dir["#{path}/**/*.rb"].sort.each do |f|
    require f
  end
end

require 'server'
require 'app'
