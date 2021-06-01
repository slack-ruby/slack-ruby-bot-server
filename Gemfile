source 'https://rubygems.org'

case ENV['DATABASE_ADAPTER']
when 'mongoid' then
  gem 'kaminari-mongoid'
  gem 'mongoid', ENV['MONGOID_VERSION'] || '~> 7.3.0'
  gem 'mongoid-scroll'
  gem 'mongoid-shell'
when 'activerecord' then
  gem 'activerecord', '~> 5.0.0'
  gem 'otr-activerecord', '~> 1.2.1'
  gem 'cursor_pagination' # rubocop:disable Bundler/OrderedGems
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
  gem 'capybara', '~> 2.15.1'
  gem 'database_cleaner', '~> 1.8.5'
  gem 'fabrication'
  gem 'faker'
  gem 'hyperclient', '~> 0.9.3'
  gem 'rack-server-pages'
  gem 'rack-test'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', '0.81.0'
  gem 'selenium-webdriver', '~> 3.4.4'
  gem 'vcr'
  gem 'webmock'
  gem 'webrick', '~> 1.6.1'
end

group :test do
  gem 'danger-toc', '~> 0.2.0', require: false
  gem 'slack-ruby-danger', '~> 0.1.0', require: false
end
