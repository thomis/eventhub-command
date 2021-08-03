desc "Database commands (run on local machine)"
command :database do |database|
  database.flag([:user], default_value: "event_hub_console", desc: "DB User")
  database.flag([:db], default_value: "event_hub_console", desc: "DB name")
  database.flag([:file], desc: "Output Filename, last backup will be taken as default")

  database.desc "Dump database from defined stage"
  database.command :dump do |dump|
    dump.action do |global_options, options, args|
      base = Eh::Settings.current.db_backups_dir
      stamp = Time.now.strftime("%Y%m%d%H%M%S")
      target = options[:file] || "#{stamp}-console-dump.sql.compressed"

      cmd = "mkdir -p #{base} && cd #{base} && pg_dump -Fc -U#{options[:user]} #{options[:db]} -f#{target}"
      puts "will execute '#{cmd}'" if global_options[:verbose]
      system cmd
      puts "Database has been dumped to #{target}".green
    end
  end

  database.desc "Restore database to defined stage"
  database.command :restore do |restore|
    restore.action do |global_options, options, args|
      source = options[:file] || begin
        base = Eh::Settings.current.db_backups_dir
        pattern = File.join(base, "*")
        files = Dir.glob(pattern).sort
        files.last
      end
      if source.nil?
        raise ArgumentError.new("No source file found in #{base} and none passed via --file")
      end
      puts "This can destroy the contents of #{options[:db]}. Is this OK? [yes/NO]:"
      answer = $stdin.gets.chomp.downcase
      if answer == "yes"
        cmd = "pg_restore -Fc -U #{options[:user]} -d #{options[:db]} #{source}"
        puts "will execute '#{cmd}'" if global_options[:verbose]
        system cmd
        puts "Database has been restored".green
      else
        puts "Aborted".green
      end
    end
  end

  database.desc "Cleanup dump files"
  database.command :cleanup do |cleanup|
    cleanup.flag([:keep], type: Integer, desc: "How many dumps to keep", default_value: 25)
    cleanup.action do |global_options, options, args|
      keep = options[:keep]
      base = Eh::Settings.current.db_backups_dir
      pattern = File.join(base, "*")
      files = Dir.glob(pattern).sort.reverse # keep most recent
      to_delete = files[keep..] || []

      to_delete.each do |file|
        puts "will delete #{file}" if global_options[:verbose]
        system "rm #{file}"
      end
      puts "Deleted #{to_delete.size} file(s)".green
    end
  end
end
