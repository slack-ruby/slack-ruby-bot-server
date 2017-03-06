source 'https://rubygems.org'

case ENV['DATABASE_ADAPTER']
when 'mongoid' then
  gem 'mongoid'
  gem 'kaminari-mongoid'
  gem 'mongoid-scroll'
when 'activerecord' then
  gem 'pg'
  gem 'activerecord'
  gem 'otr-activerecord'
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
  gem 'capybara'
  gem 'selenium-webdriver', '~> 2.5'
end

group :test do
  gem 'slack-ruby-danger', '~> 0.1.0', require: false
end
