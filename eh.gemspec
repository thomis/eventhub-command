# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','eh','version.rb'])
spec = Gem::Specification.new do |s|
  s.name                    = 'eventhub-command'
  s.date                    = Date.today.to_s
  s.version                 = Eh::VERSION
  s.author                  = ['Pascal Betz','Thomas Steiner']
  s.email                   = ['pascal.betz@simplificator.com','thomas.steiner@ikey.ch']
  s.homepage                = 'http://github.com/thomis/eventhub-command'
  s.platform                = Gem::Platform::RUBY
  s.description             = 'Event Hub Command Line Tool which supports you with various Event Hub related administrative development features.'
  s.summary                 = 'Event Hub Command Line Tool'
  s.license                 = 'MIT'
  s.files                   = Dir.glob('{bin,lib}/**/*') + %w(README.md CHANGELOG.md)
  s.require_paths           = ['lib']
  s.bindir                  = 'bin'
  s.executables             = ['eh']
  s.required_ruby_version   = '>= 1.9.3'

  s.add_development_dependency('rake', '~> 10.1')
  s.add_development_dependency('rdoc', '~> 4.1')
  s.add_development_dependency('aruba', '~> 0.5')

  s.add_runtime_dependency('gli','2.12.0')
  s.add_runtime_dependency('rubyzip', '~> 1.0')
  s.add_runtime_dependency('activesupport', '~> 4.1')
  s.add_runtime_dependency('net-ssh', '~> 2.9')
  s.add_runtime_dependency('colorize', '~> 0.7')
  s.add_runtime_dependency('highline', '~> 1.7')
  s.add_runtime_dependency('parseconfig', '~> 1.0')
end
