module Api
  module Helpers
    module ErrorHelpers
      extend ActiveSupport::Concern

      included do
        rescue_from :all, backtrace: true do |e|
          backtrace = e.backtrace[0..5].join("\n  ")
          Api::Middleware.logger.error "#{e.class.name}: #{e.message}\n  #{backtrace}"
          error = { type: 'other_error', message: e.message }
          error[:backtrace] = backtrace
          rack_response(error.to_json, 400)
        end
        # rescue document validation errors into detail json
        rescue_from Mongoid::Errors::Validations do |e|
          backtrace = e.backtrace[0..5].join("\n  ")
          Api::Middleware.logger.warn "#{e.class.name}: #{e.message}\n  #{backtrace}"
          rack_response({
            type: 'param_error',
            message: e.document.errors.full_messages.uniq.join(', ') + '.',
            detail: e.document.errors.messages.each_with_object({}) do |(k, v), h|
              h[k] = v.uniq
            end
          }.to_json, 400)
        end
        rescue_from Grape::Exceptions::Validation do |e|
          backtrace = e.backtrace[0..5].join("\n  ")
          Api::Middleware.logger.warn "#{e.class.name}: #{e.message}\n  #{backtrace}"
          rack_response({
            type: 'param_error',
            message: 'Invalid parameters.',
            detail: { e.params.join(', ') => [e.message] }
          }.to_json, 400)
        end
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          backtrace = e.backtrace[0..5].join("\n  ")
          Api::Middleware.logger.warn "#{e.class.name}: #{e.message}\n  #{backtrace}"
          rack_response({
            type: 'param_error',
            message: 'Invalid parameters.',
            detail: e.errors.each_with_object({}) do |(k, v), h|
              # JSON does not permit having a key of type Array
              h[k.count == 1 ? k.first : k.join(', ')] = v
            end
          }.to_json, 400)
        end
      end
    end
  end
end
