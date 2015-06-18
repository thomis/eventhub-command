desc 'dump and restore db. Attention: those commands run on the local machine, not remote.'
command :db do |command|

  command.switch([:v, :verbose], :desc => 'Show additional output.')
  command.flag([:user], default_value: 'event_hub_console', desc: 'DB User')
  command.flag([:db], default_value: 'event_hub_console', desc: 'DB name')
  command.flag([:file], desc: "Output Filename, last backup will be taken as default")

  command.command :dump do |c|
    c.action do |global_options, options, args|
      base = Eh::Settings.current.db_backups_dir
      stamp = Time.now.strftime('%Y%m%d%H%M%S')
      target = options[:file] || "#{stamp}-console-dump.sql.compressed"

      cmd = "mkdir -p #{base} && cd #{base} && pg_dump -Fc -U#{options[:user]} #{options[:db]} -f#{target}"
      if options[:verbose]
        puts "will execute '#{cmd}'"
      end
      system cmd
      puts "Dumped DB to #{target}"
    end
  end

  command.command :restore do |c|
    c.action do |global_options, options, args|
      source = options[:file] || begin
        base = Eh::Settings.current.db_backups_dir
        pattern = File.join(base, '*')
        files = Dir.glob(pattern).sort
        files.last
      end
      if source.nil?
        raise ArgumentError.new("No source file found in #{base} and none passed via --file")
      end
      puts "This can destroy the contents of #{options[:db]}. Is this OK? [yes/NO]:"
      answer = $stdin.gets.chomp.downcase
      if answer == 'yes'
        cmd = "pg_restore -Fc -U #{options[:user]} -d #{options[:db]} #{source}"
        if options[:verbose]
          puts "will execute '#{cmd}'"
        end
        system cmd
      else
        puts "Abort."
      end
    end
  end

  command.command :cleanup_dumps do |c|
    c.flag([:keep], type: Integer, desc: "How many dumps to keep", default_value: 25)
    c.action do |global_options, options, args|
      keep = options[:keep]
      base = Eh::Settings.current.db_backups_dir
      pattern = File.join(base, '*')
      files = Dir.glob(pattern).sort.reverse # keep most recent
      to_delete = files[keep..-1] || []

      to_delete.each do |file|
        if options[:verbose]
          puts "will delete #{file}"
        end
        system "rm #{file}"
      end
      puts "deleted #{to_delete.size} file(s)"
    end
  end

end
