module Grape
  module Extensions
    module SortExtension
      def sort(value)
        route_setting :sort, sort: value
        value
      end

      Grape::API.extend self
    end
  end
end
