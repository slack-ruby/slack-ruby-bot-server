%w(bson/object_id grape/sort_extension slack-ruby-bot).each do |ext|
  require_relative "ext/#{ext}"
end
