desc 'Packages processors to zip files'
command :package do |c|
  c.flag([:x, :exclude], :desc => "Exclude processors by name.", :type => Array, :long_desc => "You can specify multiple processors by providing a comma-separated list.")
  c.flag([:p, :processors], :desc => "Specify what processors to package", :type => Array, :long_desc => "You can specify multiple processors by providing a comma-separated list.")
  c.flag([:d, :destination], :desc => "Destination directory to place created zip files.", :default_value => Eh::Settings.current.package_tmp_dir)
  c.flag([:s, :source], :desc => "Source directory to read processors from.", :default_value => Eh::Settings.current.processes_src_dir)

  c.action do |global_options, options, args|
    source_dir = options['s']
    destination_dir = options['d']

    puts "Will package processors from #{source_dir} to #{destination_dir}"
    # find all processors in the base directory
    processor_names = Dir["#{source_dir}/*"].map do |dir|
      File.basename(dir)
    end

    included_processor_names = processor_names

    # only include processors specified by -p option, if option is given
    if options['p']
      included_processor_names = included_processor_names.select do |processor_name|
        options['p'].include?(processor_name)
      end
    end

    # exclude processors specified by -x option, if option is given
    if options['x']
      # check if any processor has been excluded from packaging
      included_processor_names = included_processor_names.select do |processor_name|
        !options['x'].include?(processor_name)
      end
    end

    # make sure we have at least one processor
    if included_processor_names.empty?
      raise "There are no processor names. Either your -s directory is empty or you specified a strange combination of -x and -p"
    end


    # make sure destination directory exists
    FileUtils.mkdir_p(destination_dir)

    # Zip all processors
    included_processor_names.each do |processor_name|

      source = File.join(source_dir, processor_name)
      destination = File.join(destination_dir, "#{processor_name}.zip")

      puts "Packaging '#{processor_name}'"

      arguments = ['tmp', 'logs', 'exceptions'].map do |item|
        expanded = File.join(source, item, '*')
        "-x \"#{expanded}\""
      end.join(' ')
      arguments << " -q" unless arguments['v']

      cmd = "zip -FS -r #{destination} #{source} #{arguments}"
      puts "Packaging '#{processor_name}' to #{destination} with \"#{cmd}\"" if global_options['v']
      system(cmd)
    end

    puts "Done packaging #{included_processor_names.size} processors"
  end
end
