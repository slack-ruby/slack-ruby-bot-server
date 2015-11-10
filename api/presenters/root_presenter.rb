module Api
  module Presenters
    module RootPresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      link :self do |opts|
        "#{base_url(opts)}/api/"
      end

      link :teams do |opts|
        {
          href: "#{base_url(opts)}/api/teams/#{PAGINATION_PARAMS}",
          templated: true
        }
      end

      [:team].each do |model|
        link model do |opts|
          {
            href: "#{base_url(opts)}/api/#{model.to_s.pluralize}/{id}",
            templated: true
          }
        end
      end

      private

      def base_url(opts)
        request = Grape::Request.new(opts[:env])
        request.base_url
      end

      PAGINATION_PARAMS = "{?#{Api::Helpers::PaginationParameters::ALL.join(',')}}"
    end
  end
end
