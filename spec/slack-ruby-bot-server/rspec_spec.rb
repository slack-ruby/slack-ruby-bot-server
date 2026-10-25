require 'spec_helper'
require 'open3'
require 'rbconfig'

describe 'RSpec fabricators' do
  let(:application_fabricator) do
    <<~RUBY
      Fabricator(:team, class_name: 'Team') do
        name { 'Application team' }
        token { 'application-token' }
        team_id { 'TAPPLICATION' }
      end
    RUBY
  end

  def fabricator_names_after(code)
    script = <<~RUBY
      require 'logger'
      Bundler.require
      require 'fabrication'
      require 'json'
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
      end
      #{code}
      puts JSON.generate(
        application: Fabricate.build(:team).name,
        framework: Fabricate.build(:slack_ruby_bot_server_team, name: 'Framework team').name
      )
    RUBY
    output, error, status = Open3.capture3(RbConfig.ruby, '-Ilib', '-rbundler/setup', '-e', script)
    expect(status.success?).to be(true), "#{output}\n#{error}"
    JSON.parse(output.lines.last)
  end

  it 'persists framework installations with unique credentials independently of the legacy name' do
    first = Fabricate(:slack_ruby_bot_server_team)
    second = Fabricate(:slack_ruby_bot_server_team)
    expect(Team.find(first.id).token).to eq first.token
    expect(first.token).not_to eq second.token
    expect(first.team_id).not_to eq second.team_id
  end

  it 'keeps the legacy helper working without an application fabricator' do
    names = fabricator_names_after("require 'slack-ruby-bot-server/rspec'")
    expect(names['application']).not_to be_empty
    expect(names['framework']).to eq 'Framework team'
  end

  it 'preserves an application fabricator registered before the legacy helper' do
    names = fabricator_names_after(<<~RUBY)
      #{application_fabricator}
      require 'slack-ruby-bot-server/rspec'
    RUBY
    expect(names).to eq('application' => 'Application team', 'framework' => 'Framework team')
  end

  it 'allows applications to inherit and customize framework defaults' do
    names = fabricator_names_after(<<~RUBY)
      require 'slack-ruby-bot-server/rspec/fabricators'
      Fabricator(:team, from: :slack_ruby_bot_server_team) do
        name { 'Application team' }
      end
    RUBY
    expect(names).to eq('application' => 'Application team', 'framework' => 'Framework team')
  end

  %w[before after].each do |order|
    it "allows an application fabricator #{order} the prefixed-only helper" do
      setup = [application_fabricator, "require 'slack-ruby-bot-server/rspec/fabricators'"]
      setup.reverse! if order == 'after'
      expect(fabricator_names_after(setup.join("\n"))).to eq(
        'application' => 'Application team', 'framework' => 'Framework team'
      )
    end
  end
end
