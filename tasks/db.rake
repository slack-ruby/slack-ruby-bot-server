namespace :db do
  def logger
    @logger ||= begin
      STDOUT.sync = true
      Logger.new(STDOUT)
    end
  end
end
