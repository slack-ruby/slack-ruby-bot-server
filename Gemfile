source 'https://rubygems.org'

case ENV['DATABASE_ADAPTER']
when 'mongoid' then
  gem 'kaminari-mongoid'
  gem 'mongoid', ENV['MONGOID_VERSION'] || '~> 7.3.0'
  gem 'mongoid-scroll'
  gem 'mongoid-shell'
when 'activerecord' then
  gem 'activerecord', '~> 6.0.0'
  gem 'otr-activerecord'
  gem 'cursor_pagination', github: 'dblock/cursor_pagination', branch: 'misc' # rubocop:disable Bundler/OrderedGems
  gem 'pg'
when nil
  warn "Missing ENV['DATABASE_ADAPTER']."
else
  warn "Invalid ENV['DATABASE_ADAPTER']: #{ENV['DATABASE_ADAPTER']}."
end

gemspec

group :development, :test do
  gem 'bundler'
  gem 'byebug'
  gem 'capybara', '~> 3.36.0'
  gem 'database_cleaner', '~> 1.8.5'
  gem 'fabrication'
  gem 'faker'
  gem 'faraday', '0.17.5'
  gem 'hyperclient', '~> 0.9.3'
  gem 'rack-server-pages'
  gem 'rack-test'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', '0.81.0'
  gem 'selenium-webdriver', '~> 4.1.0'
  gem 'vcr'
  gem 'webmock'
  gem 'webrick', '~> 1.6.1'
end
