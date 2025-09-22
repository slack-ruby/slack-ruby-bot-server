source 'https://rubygems.org'

case ENV.fetch('DATABASE_ADAPTER', nil)
when 'mongoid' then
  gem 'kaminari-mongoid'
  gem 'mongoid', ENV['MONGOID_VERSION'] || '~> 7.3.0'
  gem 'mongoid-scroll', '~> 2.0'
  gem 'mongoid-shell'
  gem 'mutex_m'

  group :development, :test do
    gem 'database_cleaner-mongoid', '~> 2.0.1'
  end
when 'activerecord' then
  gem 'activerecord', ENV['ACTIVERECORD_VERSION'] || '~> 6.0.0'
  gem 'otr-activerecord'
  gem 'pagy_cursor', '~> 0.6.1'
  gem 'pg'

  group :development, :test do
    gem 'database_cleaner-active_record', '~> 2.2.0'
  end
when nil
  warn "Missing ENV['DATABASE_ADAPTER']."
else
  warn "Invalid ENV['DATABASE_ADAPTER']: #{ENV.fetch('DATABASE_ADAPTER', nil)}."
end

gemspec

group :development, :test do
  gem 'bundler'
  gem 'byebug'
  gem 'capybara', '~> 3.40.0'
  gem 'fabrication'
  gem 'faker'
  gem 'faraday', '0.17.5'
  gem 'hyperclient', '~> 0.9.3'
  gem 'rack', '~> 2.2.3'
  gem 'rack-server-pages'
  gem 'rack-test'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', '1.80.2'
  gem 'selenium-webdriver', '~> 4.35.0'
  gem 'vcr'
  gem 'webmock'
  gem 'webrick', '~> 1.9.1'
end
