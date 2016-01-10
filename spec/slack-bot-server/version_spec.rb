require 'spec_helper'

describe SlackBotServer do
  it 'has a version' do
    expect(SlackBotServer::VERSION).to_not be nil
  end
end
