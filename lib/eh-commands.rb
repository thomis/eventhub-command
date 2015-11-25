# All commands are required here
if Eh::Settings.current.repository
  require 'eh/commands/generate_processor'
  require 'eh/commands/stage'
  require 'eh/commands/dump'
  require 'eh/commands/db'
  require 'eh/commands/proxy'
  require 'eh/commands/deploy'
  require 'eh/commands/package'
  require 'eh/proxy/proxy'
else
  # remove unused settings for this version
  Eh::Settings.current.data.delete('repository_root_dir')
  Eh::Settings.current.write
  puts "No current repository found."
  puts "You can configure other repositories by running 'eh repository add' and/or 'eh repository select'"
end

require 'eh/commands/repository'
