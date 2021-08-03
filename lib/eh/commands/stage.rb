desc "Manage stages"
command :stage do |command|
  command.desc "List defined stages"
  command.command :list do |list|
    list.action do |global_options, options, args|
      dir = Eh::Settings.current.stages_dir
      puts "Checking in #{dir}".yellow if global_options[:verbose]
      puts "Available Stages"
      Dir.glob(File.join(dir, "*.yml")) do |name|
        stage_name = File.basename(name, ".*")
        is_default = Eh::Settings.current.default_stage == stage_name
        puts " - #{stage_name} #{is_default ? "(default)" : nil}".send(is_default ? :green : :white)
      end
    end
  end

  command.desc "Select default stage"
  command.arg_name "NAME"
  command.command :select do |default|
    default.action do |global_options, options, args|
      new_stage = args[0]

      if args.size != 1
        raise "Needs a stage NAME to select"
      end

      # check if new_stage.yml exist in stages folder
      unless File.exist?(File.join(Eh::Settings.current.stages_dir, "#{new_stage}.yml"))
        raise "Stage [#{new_stage}] is not defined yet"
      end

      Eh::Settings.current.data["default_stage"] = new_stage
      Eh::Settings.current.write
      puts "Default stage selected: #{new_stage}".green
    end
  end

  command.default_command :list
end
