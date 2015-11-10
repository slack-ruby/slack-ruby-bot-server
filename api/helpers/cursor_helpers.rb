module Api
  module Helpers
    module CursorHelpers
      extend ActiveSupport::Concern

      # apply cursor-based pagination to a collection
      # returns a hash:
      #   results: (paginated collection subset)
      #   next: (cursor to the next page)
      def paginate_by_cursor(coll, &_block)
        fail 'Both cursor and offset parameters are present, these are mutually exclusive.' if params.key?(:offset) && params.key?(:cursor)
        results = { results: [], next: nil }
        size = (params[:size] || 10).to_i
        if params.key?(:offset)
          skip = params[:offset].to_i
          coll = coll.skip(skip)
        end
        # some items may be skipped with a block
        query = block_given? ? coll : coll.limit(size)
        query.scroll(params[:cursor]) do |record, next_cursor|
          record = yield(record) if block_given?
          results[:results] << record if record
          results[:next] = next_cursor.to_s
          break if results[:results].count >= size
        end
        results[:total_count] = coll.count if params[:total_count] && coll.respond_to?(:count)
        results
      end

      def paginate_and_sort_by_cursor(coll, options = {}, &block)
        Hashie::Mash.new(paginate_by_cursor(sort(coll, options), &block))
      end
    end
  end
end
