desc 'Packages processors to zip files'
command :release do |c|
  c.flag([:d, :destination], :desc => "Destination directory to place created zip files.", :default_value => Eh::Settings.current.release_dir)
  c.flag([:s, :source], :desc => "Source directory to read processors from.", :default_value => Eh::Settings.current.package_tmp_dir)

  c.action do |global_options, options, args|
    source_dir = options['s']
    destination_dir = options['d']
    pattern = "#{source_dir}/*.zip"
    cmd = "cp #{pattern} #{destination_dir}"
    puts "Will copy #{Dir[pattern].size} files from #{source_dir} to #{destination_dir}"
    puts "Command: #{cmd}" if global_options['v']
    system cmd
    puts "Done."
  end
end
