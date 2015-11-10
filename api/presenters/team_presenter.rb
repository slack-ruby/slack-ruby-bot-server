module Api
  module Presenters
    module TeamPresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :id, type: String, desc: 'Team ID.'
      property :token, type: String, desc: 'Team token.'
      property :created_at, type: DateTime, desc: 'Date/time when the team was created.'

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.base_url}/api/teams/#{id}"
      end
    end
  end
end
