desc "Manage repositories"

command :repository do |command|
  command.desc "Lists all avaiable repositories"
  command.command :list do |command|
    command.action do |global_options,options,args|

      puts "Defined Repositories [#{Eh::Settings.current.data['repositories'].size}]"
      Eh::Settings.current.repositories.each_with_index do |repository, index|
        if repository.current?
          puts " #{index+1}. #{repository.url} (current)".green
        else
          puts " #{index+1}. #{repository.url}"
        end
      end
    end
  end

  command.desc "Selects a repository by INDEX"
  command.arg_name 'INDEX'
  command.command :select do |command|
    command.action do |global_options,options,args|
      if Eh::Settings.current.repositories.length == 0
        raise "No repository configured so far"
      end
      if args.length != 1
        raise "Needs mandatory INDEX argument"
      end
      selected = args[0].to_i
      if selected > Eh::Settings.current.data['repositories'].size
        raise "Argument INDEX is out of range"
      end
      Eh::Settings.current.data['repositories'].each_with_index do |repository, index|
        repository['current'] = (index + 1) == selected
      end
      Eh::Settings.current.write
      puts "Repository selected: #{Eh::Settings.current.repository.url}".green
    end
  end

  command.desc 'Add a repository with URL DIR USERNAME PASSWORD'
  command.arg_name 'URL DIR USERNAME PASSWORD'
  command.command :add do |command|
    command.action do |global_options, options, args|
      if args.length != 4
        raise "Need exactly 4 arguments: URL, DIR, USERNAME, PASSWORD"
      end
      Eh::Settings.current.data['repositories'] ||= []

      # check if same repo already exists
      exists = Eh::Settings.current.data['repositories'].any? do |repository|
        repository['url'] == args[0]
      end
      if exists
        raise "Already configured repository [#{args[0]}]"
      end

      Eh::Settings.current.data['repositories'] << {
        'url' => args[0],
        'dir' => File::ALT_SEPARATOR ? args[1].gsub(File::ALT_SEPARATOR, File::SEPARATOR) : args[1],
        'deploy_username' => args[2],
        'deploy_password' => args[3],
        'current' => (Eh::Settings.current.data['repositories'].length == 0)
      }
      Eh::Settings.current.write

      puts "New Repository [#{args[0]}] has beed added. Total Repositories: #{Eh::Settings.current.data['repositories'].size}".green
    end
  end


  command.desc 'Remove a repository by INDEX'
  command.arg_name 'INDEX'
  command.command :remove do |command|
    command.action do |global_options, options, args|

      if args.length != 1
        raise "Needs mandatory INDEX argument"
      end
      selected = args[0].to_i

      if Eh::Settings.current.repositories[selected - 1].nil?
        raise "No repository with index [selected]"
      end

      Eh::Settings.current.data['repositories'].delete_at(selected - 1)
      Eh::Settings.current.write

      puts "Repository has been removed. Total Repositories: #{Eh::Settings.current.data['repositories'].size}".green
    end
  end

  command.default_command :list
end
