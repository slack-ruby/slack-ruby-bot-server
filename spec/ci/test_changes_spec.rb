require 'spec_helper'
require 'open3'
require 'tmpdir'
require 'fileutils'

describe 'CI test change classification' do
  around do |example|
    Dir.mktmpdir('test-changes') do |directory|
      @repository = directory
      example.run
    end
  end

  before do
    git('init', '--quiet')
    git('config', 'user.name', 'CI')
    git('config', 'user.email', 'ci@example.invalid')
    @base = commit('README.md')
  end

  def git(*args)
    output, error, status = Open3.capture3('git', *args, chdir: @repository)
    raise error unless status.success?

    output.strip
  end

  def commit(path)
    FileUtils.mkdir_p(File.dirname(File.join(@repository, path)))
    File.write(File.join(@repository, path), "content for #{path}\n")
    git('add', '--all')
    git('commit', '--quiet', '-m', 'Test change')
    git('rev-parse', 'HEAD')
  end

  def classify(base: @base, head: git('rev-parse', 'HEAD'), event: 'pull_request')
    output = File.join(@repository, 'output')
    script = File.expand_path('../../.github/scripts/test-changes.sh', __dir__)
    _, error, status = Open3.capture3(
      { 'EVENT_NAME' => event, 'BASE_SHA' => base, 'HEAD_SHA' => head, 'GITHUB_OUTPUT' => output },
      'bash', script, chdir: @repository
    )
    raise error unless status.success?

    File.read(output).strip
  end

  it 'skips Markdown and documentation images' do
    commit('docs/guide.md')
    commit('images/example.png')
    expect(classify).to eq 'run_tests=false'
  end

  it 'runs tests when documentation is mixed with runtime changes' do
    commit('UPGRADING.md')
    commit('public/styles.css')
    expect(classify).to eq 'run_tests=true'
  end

  it 'does not ignore a code file renamed to Markdown' do
    @base = commit('lib/example.rb')
    File.rename(File.join(@repository, 'lib/example.rb'), File.join(@repository, 'example.md'))
    git('add', '--all')
    git('commit', '--quiet', '-m', 'Rename')
    expect(classify).to eq 'run_tests=true'
  end

  it 'compares pull requests from their merge base, not unrelated base-branch changes' do
    head = commit('CHANGELOG.md')
    git('checkout', '--quiet', '--detach', @base)
    base = commit('lib/base-only.rb')
    expect(classify(base: base, head: head)).to eq 'run_tests=false'
  end

  it 'includes removed code when a push rewrites history' do
    before = commit('lib/removed.rb')
    git('checkout', '--quiet', '--detach', @base)
    head = commit('CHANGELOG.md')
    expect(classify(base: before, head: head, event: 'push')).to eq 'run_tests=true'
  end

  it 'runs the full matrix for a new branch' do
    expect(classify(base: '0' * 40, event: 'push')).to eq 'run_tests=true'
  end

  it 'runs the full matrix when a previous pushed revision is unavailable' do
    expect(classify(base: 'f' * 40, event: 'push')).to eq 'run_tests=true'
  end

  it 'fails instead of silently skipping tests when a pull request comparison is invalid' do
    expect { classify(base: 'f' * 40) }.to raise_error(RuntimeError)
  end
end
