source 'https://rubygems.org'

case ENV['DATABASE_ADAPTER']
when 'mongoid' then
  gem 'kaminari-mongoid'
  gem 'mongoid'
  gem 'mongoid-scroll'
when 'activerecord' then
  gem 'activerecord', '~> 5.0.0'
  gem 'otr-activerecord', '~> 1.2.1'
  gem 'cursor_pagination' # rubocop:disable Bundler/OrderedGems
  gem 'pg'
when nil then
  warn "Missing ENV['DATABASE_ADAPTER']."
else
  warn "Invalid ENV['DATABASE_ADAPTER']: #{ENV['DATABASE_ADAPTER']}."
end

gemspec

group :development, :test do
  gem 'bundler'
  gem 'byebug'
  gem 'capybara', '~> 2.15.1'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
  gem 'hyperclient'
  gem 'mongoid-shell'
  gem 'rack-server-pages'
  gem 'rack-test'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', '0.58.2'
  gem 'selenium-webdriver', '~> 3.4.4'
  gem 'vcr'
  gem 'webmock'
end

group :test do
  gem 'slack-ruby-danger', '~> 0.1.0', require: false
end
