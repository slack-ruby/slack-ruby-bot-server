module SlackBotServer
  class Tokens < Grape::API
    format :json
    get '/tokens' do
      []
    end
  end
end
