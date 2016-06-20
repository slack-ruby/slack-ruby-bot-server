namespace :db do
  def logger
    @logger ||= begin
      $stdout.sync = true
      Logger.new(STDOUT)
    end
  end

  namespace :heroku do
    desc 'Mongodump the BotServer database for a slack-ruby-bot-server Heroku app.'
    task :backup, [:app] do |_t, args|
      require 'mongoid-shell'

      logger.info("[#{Time.now}] db:heroku:backup started")

      # get heroku configuration info
      app = args[:app] || raise('Missing app.')
      JSON.parse(`bundle exec heroku config --app #{app} --json`).each_pair do |k, v|
        ENV[k] = v
      end

      # connect to MongoDB
      env = (ENV['RACK_ENV'] || 'development').to_s
      logger.info "Connecting to the #{env} environment."
      Mongoid.load! 'config/mongoid.yml', env

      # mongodump
      mongodump = Mongoid::Shell::Commands::Mongodump.new(session: Mongoid.default_client)
      mongodump.out = File.join(Dir.tmpdir, 'db/' + mongodump.host.tr(':', '_'))
      logger.info("[#{Time.now}] clearing (#{mongodump.out})")
      FileUtils.rm_rf mongodump.out if File.directory? mongodump.out
      logger.info("[#{Time.now}] mongodump to #{mongodump.out}")
      system mongodump.to_s

      # backup
      backup_name = "#{app}-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}"
      tmp_db_filename = File.join(mongodump.out, backup_name)
      logger.info("[#{Time.now}] compressing (#{tmp_db_filename}.tar.gz)")
      system "tar -cvf #{tmp_db_filename}.tar #{mongodump.out}/#{mongodump.db}"
      system "gzip #{tmp_db_filename}.tar"
      logger.info "Created #{tmp_db_filename}.tar.gz."
    end
  end
end
