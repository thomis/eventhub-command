require "date"

# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__), "lib", "eh", "version.rb"])
Gem::Specification.new do |s|
  s.name = "eventhub-command"
  s.version = Eh::VERSION
  s.author = ["Pascal Betz", "Thomas Steiner"]
  s.email = ["pascal.betz@simplificator.com", "thomas.steiner@ikey.ch"]
  s.homepage = "http://github.com/thomis/eventhub-command"
  s.platform = Gem::Platform::RUBY
  s.description = "Event Hub Command Line Tool which supports you with various Event Hub related administrative development features."
  s.summary = "Event Hub Command Line Tool"
  s.license = "MIT"
  s.files = Dir.glob("{bin,lib}/**/*") + %w[README.md CHANGELOG.md]
  s.require_paths = ["lib"]
  s.bindir = "bin"
  s.executables = ["eh"]
  s.required_ruby_version = ">= 2.4"

  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency("rake", "~> 13.0")
  s.add_development_dependency("rspec", "~> 3.10")
  s.add_development_dependency("standard", "~> 1.1.5")
  s.add_development_dependency("simplecov", "~> 0.21.2")

  s.add_runtime_dependency("gli", "~> 2.17")
  s.add_runtime_dependency("rubyzip", "~> 2.3")
  s.add_runtime_dependency("net-ssh", "~> 6.1")
  s.add_runtime_dependency("colorize", "~> 0.8")
  s.add_runtime_dependency("highline", "~> 2.0")
  s.add_runtime_dependency("parseconfig", "~> 1.0")
end
