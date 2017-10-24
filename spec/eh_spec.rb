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

  it 'shows help with help' do
    response = `bin/eh help`
    expect(response).to match(/command line tools for eventhub/i)
  end

  it 'shows help with no option given' do
    response = `bin/eh`
    expect(response).to match(/command line tools for eventhub/i)
  end

  it 'shows help for various commands' do

    command_help_map = [
      ['generate', 'Generate template for a new processor'],
      ['generate ruby', 'Generate ruby based processor'],

      ['package', 'Package commands'],
      ['package ruby', 'Packages ruby processors to zip files'],
      ['package go', 'Packages go processors to zip files'],
      ['package rails', 'Packages rails console app to zip file'],

      ['deploy', 'Deployment commands'],
      ['deploy all', 'Deploy all components'],
      ['deploy config', 'Deploy configuration files'],
      ['deploy console', 'Deploy rails console'],
      ['deploy mule', 'Deploy channel adapter'],
      ['deploy ruby', 'Deploy ruby processor'],
      ['deploy go', 'Deploy go processor'],

      ['stage', 'Manage stages'],
      ['stage list', 'List defined stages'],
      ['stage select', 'Select default stage'],

      ['repository', 'Manage repositories'],
      ['repository list', 'Lists all avaiable repositories'],
      ['repository select', 'Selects a repository by INDEX'],
      ['repository add', 'Add a repository with URL DIR USERNAME PASSWORD'],
      ['repository remove', 'Remove a repository by INDEX'],

      ['proxy', 'Manage proxies'],
      ['proxy list', 'List defined proxies'],
      ['proxy select', 'Select proxy by NAME'],
      ['proxy on', 'Enable proxy default or by NAME'],
      ['proxy off', 'Disable default proxy'],
      ['proxy add', 'Add new proxy by NAME and PROXY_URL'],
      ['proxy remove', 'Remove by NAME'],

      ['dump', 'Creating a dump from an eventhub environment'],
      ['dump download', 'Download dumped database'],
      ['dump create', 'Create dump file from database'],

      ['database', 'Database commands'],
      ['database dump', 'Dump database from defined stage'],
      ['database restore', 'Restore database to defined stage'],
      ['database cleanup', 'Cleanup dump files']
    ]

    command_help_map.each do |command, help|
      response = `bin/eh help #{command}`
      expect(response).to match(Regexp.new(help, Regexp::MULTILINE))
    end
  end

end
