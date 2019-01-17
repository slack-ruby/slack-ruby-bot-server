module Grape
  class API
    module Extensions
      module SortExtension
        def sort(value)
          route_setting :sort, sort: value
          value
        end
      end
    end
  end
end

if defined? Grape::API::Instance
  Grape::API::Instance.extend Grape::API::Extensions::SortExtension
else
  Grape::API.extend Grape::API::Extensions::SortExtension
end
