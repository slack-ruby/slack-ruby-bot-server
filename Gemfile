source 'https://rubygems.org'

case ENV['DATABASE_ADAPTER']
when 'mongoid' then
  gem 'mongoid'
  gem 'kaminari-mongoid'
  gem 'mongoid-scroll'
when 'activerecord' then
  gem 'pg'
  gem 'activerecord', '~> 5.0.0'
  gem 'otr-activerecord', '~> 1.2.1'
  gem 'cursor_pagination'
when nil then
  warn "Missing ENV['DATABASE_ADAPTER']."
else
  warn "Invalid ENV['DATABASE_ADAPTER']: #{ENV['DATABASE_ADAPTER']}."
end

gemspec

group :development, :test do
  gem 'rack-server-pages'
  gem 'bundler'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', '0.40.0'
  gem 'byebug'
  gem 'mongoid-shell'
  gem 'heroku'
  gem 'rack-test'
  gem 'webmock'
  gem 'vcr'
  gem 'fabrication'
  gem 'faker'
  gem 'database_cleaner'
  gem 'hyperclient'
  gem 'capybara', '~> 2.15.1'
  gem 'selenium-webdriver', '~> 3.4.4'
end

group :test do
  gem 'slack-ruby-danger', '~> 0.1.0', require: false
end
