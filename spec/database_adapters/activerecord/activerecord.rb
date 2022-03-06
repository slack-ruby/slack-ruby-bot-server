db_config = YAML.safe_load(
  ERB.new(File.read(
            File.expand_path('config/postgresql.yml', __dir__)
          )).result, [], [], true
)[ENV['RACK_ENV']]
ActiveRecord::Tasks::DatabaseTasks.create(db_config)
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Base.logger.level = :info
