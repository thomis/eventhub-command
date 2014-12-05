# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','eh','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'eventhub-command'
  s.version = Eh::VERSION
  s.author = ['Pascal Betz','Thomas Steiner']
  s.email = ['pascal.betz@simplificator.com','thomas.steiner@ikey.ch']
  s.homepage = 'http://github.com/thomis/eventhub-command'
  s.platform = Gem::Platform::RUBY
  s.description = 'Event Hub Command Line Tool which supports you with various Event Hub related administrative development features.'
  s.summary = 'Event Hub Command Line Tool'
  s.license = "MIT"
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md','eh.rdoc']
  s.rdoc_options << '--title' << 'eh' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'eh'
  s.add_development_dependency('rake', '~> 10.1')
  s.add_development_dependency('rdoc', '~> 4.1')
  s.add_development_dependency('aruba', '~> 0.5')
  s.add_runtime_dependency('gli','2.12.0')
  s.add_runtime_dependency('rubyzip', '~> 1.0')
  s.add_runtime_dependency('activesupport', '~> 4.1')
  s.add_runtime_dependency('net-scp')
  s.add_runtime_dependency('net-ssh-open3')

end
