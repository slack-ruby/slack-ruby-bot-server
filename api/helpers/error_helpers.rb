module Api
  module Helpers
    module ErrorHelpers
      extend ActiveSupport::Concern

      included do
        rescue_from :all, backtrace: true do |e|
          error = { type: 'other_error', message: e.message }
          rack_response(error.to_json, 400)
        end
        # rescue document validation errors into detail json
        rescue_from Mongoid::Errors::Validations do |e|
          rack_response({
            type: 'param_error',
            message: e.document.errors.full_messages.uniq.join(', ') + '.',
            detail: e.document.errors.messages.inject({}) do |h, (k, v)|
              h[k] = v.uniq
              h
            end
          }.to_json, 400)
        end
      end
    end
  end
end
