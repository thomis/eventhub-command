require 'spec_helper'

RSpec.describe Eh::Settings do

  before(:each) do
    @settings = Eh::Settings.load('spec/fixtures/eh.json')
  end

  it 'initializes settings' do
    expect(@settings.class).to eq(Eh::Settings)
  end

  it 'has a releases dir' do
    expect(@settings.releases_dir).to eq('/data/project1/branches/master/releases')
  end

  it 'has a rails release dir' do
    expect(@settings.rails_release_dir).to eq('/data/project1/branches/master/releases/rails')
  end

  it 'has a ruby release dir' do
    expect(@settings.ruby_release_dir).to eq('/data/project1/branches/master/releases/ruby')
  end

  it 'has a go release dir' do
    expect(@settings.go_release_dir).to eq('/data/project1/branches/master/releases/go')
  end

  it 'has a ruby processors dir' do
    expect(@settings.ruby_processors_src_dir).to eq('/data/project1/branches/master/src/ruby')
  end

  it 'has a go processors dir' do
    expect(@settings.go_processors_src_dir).to eq('/data/project1/branches/master/src/go/src/github.com/cme-eventhub')
  end

  it 'has a rails dir' do
    expect(@settings.rails_src_dir).to eq('/data/project1/branches/master/src/rails/console')
  end

  it 'has a console source dir' do
    expect(@settings.console_source_dir).to eq('/data/project1/branches/master/src/rails/console')
  end

  it 'has a deployment dir' do
    expect(@settings.deployment_dir).to eq('/data/project1/branches/master/src/deployment')
  end

  it 'has a source config dir' do
    expect(@settings.source_config_dir).to eq('/data/project1/branches/master/config')
  end

end