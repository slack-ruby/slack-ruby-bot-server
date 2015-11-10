module SlackBotServer
  class API < Grape::API
    prefix 'api'
    format :json
    mount ::SlackBotServer::Root
    mount ::SlackBotServer::Tokens
    add_swagger_documentation api_version: 'v1'
  end
end
