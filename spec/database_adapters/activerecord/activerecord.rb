db_config = YAML.safe_load(File.read(File.expand_path('../../../sample_apps/sample_app_activerecord/config/postgresql.yml', __dir__)), [], [], true)[ENV['RACK_ENV']]
ActiveRecord::Tasks::DatabaseTasks.create(db_config)
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Base.logger.level = :info
