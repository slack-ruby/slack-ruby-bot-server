module Methods
  extend ActiveSupport::Concern

  included do
    attr_accessor :server # server at runtime

    SORT_ORDERS = ['created_at', '-created_at', 'updated_at', '-updated_at'].freeze

    scope :active, -> { where(active: true) }

    validates_uniqueness_of :token, message: 'has already been used'
    validates_presence_of :token
    validates_presence_of :team_id

    def deactivate!
      update_attributes!(active: false)
    end

    def activate!(token)
      update_attributes!(active: true, token: token)
    end

    def to_s
      {
        name: name,
        domain: domain,
        id: team_id
      }.map do |k, v|
        "#{k}=#{v}" if v
      end.compact.join(', ')
    end

    def ping!
      client = Slack::Web::Client.new(token: token)

      auth = client.auth_test

      presence = begin
        client.users_getPresence(user: auth['user_id'])
                 rescue Slack::Web::Api::Errors::MissingScope
                   nil
      end

      {
        auth: auth,
        presence: presence
      }
    end

    def ping_if_active!
      return unless active?

      ping!
    rescue Slack::Web::Api::Errors::SlackError => e
      logger.warn "Active team #{self} ping, #{e.message}."
      case e.message
      when 'account_inactive', 'invalid_auth'
        deactivate!
      end
    end
  end
end
