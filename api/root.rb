module SlackBotServer
  class Root < Grape::API
    format :json
    get do
      {}
    end
  end
end
