desc "manage repositories"

command :repository do |command|
  command.desc "Lists all avaiable repositories"
  command.command :list do |command|
    command.action do |global_options,options,args|
      Eh::Settings.current.repositories.each_with_index do |repository, index|
        if repository.current?
          puts "#{index + 1}: #{repository.url} (current)"
        else
          puts "#{index + 1}: #{repository.url}"
        end
      end
    end
  end

  command.desc "selects a repository: eh repository select INDEX"
  command.command :select do |command|
    command.action do |global_options,options,args|
      if Eh::Settings.current.repositories.length == 0
        raise "No repository configured so far"
      end
      if args.length != 1
        raise "Need exactly 1 arguments: index"
      end
      selected = args[0].to_i
      puts "Will select #{args[0]}"
      Eh::Settings.current.data['repositories'].each_with_index do |repository, index|
        repository['current'] = (index + 1) == selected
      end
      Eh::Settings.current.write
    end
  end

  command.desc 'add a repository to the config: eh repository add URL DIR USERNAME PASSWORD'
  command.command :add do |command|
    command.action do |global_options, options, args|
      if args.length != 4
        raise "Need exactly 4 arguments: URL, DIR, USERNAME, PASSWORD"
      end
      Eh::Settings.current.data['repositories'] ||= []
      Eh::Settings.current.data['repositories'] << {
        'url' => args[0],
        'dir' => args[1],
        'deploy_username' => args[2],
        'deploy_password' => args[3],
        'current' => (Eh::Settings.current.data['repositories'].length == 0)
      }
      Eh::Settings.current.write
    end
  end


  command.desc 'remove a repository from the config: eh repository remove INDEX'
  command.command :remove do |command|
    command.action do |global_options, options, args|

      if args.length != 1
        raise "Need exactly 1 arguments: index"
      end
      selected = args[0].to_i

      if Eh::Settings.current.repositories[selected - 1].nil?
        raise "No repository with index #{selected}"
      end

      Eh::Settings.current.data['repositories'].delete_at(selected - 1)
      Eh::Settings.current.write
    end
  end
end
