require 'rubygems'
require 'bundler/gem_tasks'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb'].exclude(%r{ext\/(?!#{ENV.fetch('DATABASE_ADAPTER', nil)})})
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %i[rubocop spec]

import 'tasks/db.rake'
