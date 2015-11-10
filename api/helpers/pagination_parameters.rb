module Api
  module Helpers
    module PaginationParameters
      extend Grape::API::Helpers

      params :pagination do
        optional :offset, type: Integer, desc: 'Offset from which to retrieve.'
        optional :size, type: Integer, desc: 'Number of items to retrieve for this page or from the current offset.'
        optional :cursor, type: String, desc: 'Cursor for pagination.'
        optional :total_count, desc: 'Include total count in the response.'
        mutually_exclusive :offset, :cursor
      end

      ALL = %w(cursor size sort offset total_count)
    end
  end
end
