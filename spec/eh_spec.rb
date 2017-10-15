require "spec_helper"

RSpec.describe Eh do
  it 'has a version number' do
    expect(Eh::VERSION).not_to be nil
  end

  it 'shows help with --help' do
    response = `bin/eh --help`
    expect(response).to match(/command line tools for eventhub/i)
  end

  it 'shows help with -h' do
    response = `bin/eh -h`
    expect(response).to match(/command line tools for eventhub/i)
  end

  it 'shows help with no option given' do
    response = `bin/eh`
    expect(response).to match(/command line tools for eventhub/i)
  end

  it 'shows help for various commands' do

    command_help_map = [
      ['db', 'dump and restore Eventhub database'],
      ['deploy', 'deployment of various components'],
      ['dump', 'manage repositories'],
      ['generate', 'generate template for a new processor'],
      ['package', 'package commands'],
      ['proxy', 'enable/disable proxy'],
      ['repository', 'manage repositories'],
      ['stage', 'manage stages']
    ]

    command_help_map.each do |command, help|
      response = `bin/eh help #{command}`
      expect(response).to match(Regexp.new(help, Regexp::MULTILINE))
    end
  end

end
