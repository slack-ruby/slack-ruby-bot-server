yml = ERB.new(File.read(File.expand_path('config/postgresql.yml', __dir__))).result
db_config = if Gem::Version.new(Psych::VERSION) >= Gem::Version.new('3.1.0.pre1')
              YAML.safe_load(yml, aliases: true)[ENV.fetch('RACK_ENV', nil)]
            else
              YAML.safe_load(yml, [], [], true)[ENV.fetch('RACK_ENV', nil)]
            end
ActiveRecord::Tasks::DatabaseTasks.create(db_config)
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Base.logger ||= Logger.new(STDOUT)
ActiveRecord::Base.logger.level = :info
