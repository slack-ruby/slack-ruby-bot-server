require_relative 'ext/slack-ruby-bot/client'

module SlackRubyBotServer
  class Server < SlackRubyBot::Server
    attr_accessor :team

    def initialize(attrs = {})
      attrs = attrs.dup
      @team = attrs.delete(:team)
      raise 'Missing team' unless @team
      attrs[:token] = @team.token
      super(attrs)
      client.owner = @team
    end

    def restart!(wait = 1)
      # when an integration is disabled, a live socket is closed, which causes the default behavior of the client to restart
      # it would keep retrying without checking for account_inactive or such, we want to restart via service which will disable an inactive team
      logger.info "#{team.name}: socket closed, restarting ..."
      SlackRubyBotServer::Service.instance.restart! team, self, wait
      client.owner = team
    end
  end
end
