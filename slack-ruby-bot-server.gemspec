lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/slack-ruby-bot-server/version'

Gem::Specification.new do |spec|
  spec.name          = 'slack-ruby-bot-server'
  spec.version       = SlackRubyBotServer::VERSION
  spec.authors       = ['Daniel Doubrovkine']
  spec.email         = ['dblock@dblock.org']

  spec.summary       = 'A Grape API serving a Slack bot to multiple teams.'
  spec.homepage      = 'https://github.com/slack-ruby/slack-ruby-bot-server'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'async'
  spec.add_dependency 'foreman'
  spec.add_dependency 'grape'
  spec.add_dependency 'grape-roar', '>= 0.4.0'
  spec.add_dependency 'grape-swagger'
  spec.add_dependency 'kaminari-grape'
  spec.add_dependency 'rack-cors'
  spec.add_dependency 'rack-rewrite'
  spec.add_dependency 'rack-server-pages'
  spec.add_dependency 'slack-ruby-client'
  spec.add_dependency 'pagy_cursor'
end
