desc 'manage stages'
command :stage do |command|

  command.switch([:v, :verbose], :desc => 'Show additional output.')
  command.command :list do |c|
    c.action do |global_options, options, args|
      dir = Eh::Settings.current.stages_dir
      puts "Checking in #{dir}".green if options[:verbose]
      puts "Available stages are:".blue
      Dir.glob(File.join(dir, '*.yml')) do |name|
        stage_name = File.basename(name, '.*')
        default = '(default)' if Eh::Settings.current.default_stage == stage_name
        puts "#{stage_name} #{default}".light_blue
      end
    end
  end
  command.command :select_default do |c|
    c.action do |global_options, options, args|
      stage = args[0]
      Eh::Settings.current.data['default_stage'] = stage
      Eh::Settings.current.write
      puts "Set stage default to '#{stage}'"
    end
  end
end
