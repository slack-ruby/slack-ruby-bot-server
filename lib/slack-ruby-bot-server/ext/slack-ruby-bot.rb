%w(client commands/base).each do |ext|
  require_relative "slack-ruby-bot/#{ext}"
end
