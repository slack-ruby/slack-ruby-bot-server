# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack-bot-server/version'

Gem::Specification.new do |spec|
  # "slack-bot-server" is already taken, but that's ok since this is going to be
  # broken up into different projects according to
  # https://github.com/dblock/slack-bot-server/issues/3
  spec.name          = 'slack_bot_server'
  spec.version       = SlackBotServer::VERSION
  spec.authors       = ['Daniel Doubrovkine']
  spec.email         = ['dblock@dblock.org']

  spec.summary       = 'A Grape API serving a Slack bot to multiple teams.'
  spec.homepage      = 'https://github.com/dblock/slack-bot-server'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'slack-ruby-bot', '~> 0.8.0'
  spec.add_dependency 'celluloid-io'
  spec.add_dependency 'mongoid', '~> 5.0.0'
  spec.add_dependency 'unicorn'
  spec.add_dependency 'grape', '~> 0.15.0'
  spec.add_dependency 'grape-swagger', '~> 0.10.0'
  spec.add_dependency 'grape-roar'
  spec.add_dependency 'rack-cors'
  spec.add_dependency 'kaminari', '~> 0.16.1'
  spec.add_dependency 'mongoid-scroll'
  spec.add_dependency 'rack-robotz'
  spec.add_dependency 'newrelic_rpm'
  spec.add_dependency 'newrelic-slack-ruby-bot'
  spec.add_dependency 'rack-rewrite'
  spec.add_dependency 'rack-server-pages'
  spec.add_dependency 'foreman'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.35.1'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'mongoid-shell'
  spec.add_development_dependency 'heroku'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'fabrication'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'hyperclient'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'selenium-webdriver'
end
