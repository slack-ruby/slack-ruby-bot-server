module SlackRubyBotServer
  module Api
    module Helpers
      module CursorHelpers
        extend ActiveSupport::Concern
        include Pagy::Cursor::Backend

        # apply cursor-based pagination to a collection
        # returns a hash:
        #   results: (paginated collection subset)
        #   next: (cursor to the next page)
        if SlackRubyBotServer::Config.mongoid?
          def paginate_by_cursor(coll, _options)
            raise 'Both cursor and offset parameters are present, these are mutually exclusive.' if params.key?(:offset) && params.key?(:cursor)

            results = { results: [], next: nil }
            coll = coll.skip(params[:offset].to_i) if params.key?(:offset)
            size = (params[:size] || 10).to_i
            coll = coll.limit(size)
            coll.scroll(params[:cursor]) do |record, next_cursor|
              results[:results] << record if record
              results[:next] = next_cursor.to_s
              break if results[:results].count >= size
            end
            results[:total_count] = coll.count if params[:total_count] && coll.respond_to?(:count)
            results
          end
        elsif SlackRubyBotServer::Config.activerecord?
          def paginate_by_cursor(coll, options)
            raise 'Both cursor and offset parameters are present, these are mutually exclusive.' if params.key?(:offset) && params.key?(:cursor)

            results = { results: [], next: nil }
            size = (params[:size] || 10).to_i
            pagy_cursor, coll = pagy_cursor(coll, items: size)

            puts pagy_cursor.inspect
            results[:results] = coll.to_a
            results
          end
        end

        def paginate_and_sort_by_cursor(coll, options = {})
          Hashie::Mash.new(paginate_by_cursor(sort(coll, options), options))
        end
      end
    end
  end
end
