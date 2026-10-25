require_relative 'slack_ruby_bot_server_team'

Fabricator(:team, from: :slack_ruby_bot_server_team) unless Fabrication.manager[:team]
