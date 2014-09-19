desc 'Copies the config directory of a given processor to remote'
command :copy_config do |c|
  c.flag([:s, :source], :desc => "Source config directory", :default_value => Eh::Settings.current.source_config_dir, :long_desc => "A local directory containing subfolders for each of the processors")
  c.flag([:p, :processors], :desc => "Specify what processors' configs to copy", :type => Array, :long_desc => "You can specify multiple processors by providing a comma-separated list.")

  c.action do |global_options, options, args|
    source_config_dir = options['s']
    repository_deployment_dir = File.join(Eh::Settings.current.repository_root_dir, "branches", "master", "src", "deployment")

    processor_names = Dir["#{source_config_dir}/*"].map do |dir|
      File.basename(dir)
    end

    included_processor_names = processor_names

    # only include processors specified by -p option, if option is given
    if options['p']
      included_processor_names = included_processor_names.select do |processor_name|
        options['p'].include?(processor_name)
      end
    end

    # make sure we have at least one processor
    if included_processor_names.empty?
      raise "There are no processor configs to copy. Either there is nothing in #{source_config_dir} or the processor(s) specified with -p don't exist."
    end

    included_processor_names.each do |processor_name|
      processor_config_source_dir = File.join(source_config_dir, processor_name)

      cmd = "cd #{repository_deployment_dir} && COPY_FROM_DIR=#{processor_config_source_dir} bundle exec cap event_hub:scp_copy_config"

      puts "Will copy config files from #{processor_config_source_dir} to remote."
      puts "WARNING: This will overwrite any existing files with the same name!"
      puts "Do you really want to do this?"
      input = STDIN.gets.chomp

      unless ['y', 'Y'].include?(input)
        raise "Not confirmed. Stop."
      end

      puts "Command: #{cmd}" if global_options['v']

      Bundler.with_clean_env do
        system cmd
      end
    end

    puts "Done."
  end
end
