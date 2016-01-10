module Api
  module Presenters
    module PaginatedPresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :total_count

      link :self do |opts|
        "#{request_url(opts)}#{query_string_for_cursor(nil, opts)}"
      end

      link :next do |opts|
        "#{request_url(opts)}#{query_string_for_cursor(represented.next, opts)}" if represented.next
      end

      private

      def request_url(opts)
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}#{opts[:env]['PATH_INFO']}"
      end

      # replace the page and offset parameters in the query string
      def query_string_for_cursor(cursor, opts)
        qs = Hashie::Mash.new(Rack::Utils.parse_nested_query(opts[:env]['QUERY_STRING']))
        if cursor
          qs.merge!(cursor: cursor)
          qs.delete(:offset)
        end
        "?#{qs.to_query}" unless qs.empty?
      end
    end
  end
end
