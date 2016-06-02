module Grape
  class API
    def self.sort(value)
      route_setting :sort, sort: value
      value
    end
  end
end
