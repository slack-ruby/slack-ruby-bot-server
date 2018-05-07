require 'rubygems'
require 'bundler/setup'

require 'rspec/core'
require 'rspec/core/rake_task'

require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task default: [:spec]
