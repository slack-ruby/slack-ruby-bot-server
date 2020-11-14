%w[bson/object_id grape/sort_extension].each do |ext|
  require_relative "ext/#{ext}"
end
