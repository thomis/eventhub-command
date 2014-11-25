desc 'Packages processors to zip files'
command :package do |c|
  c.flag([:x, :exclude], :desc => "Exclude processors by name.", :type => Array, :long_desc => "You can specify multiple processors by providing a comma-separated list.")
  c.flag([:p, :processors], :desc => "Specify what processors to package", :type => Array, :long_desc => "You can specify multiple processors by providing a comma-separated list.")
  c.flag([:d, :destination], :desc => "Destination directory to place created zip files.", :default_value => Eh::Settings.current.ruby_release_dir)
  c.flag([:s, :source], :desc => "Source directory to read processors from.", :default_value => Eh::Settings.current.processors_src_dir)

  c.action do |global_options, options, args|
    source_dir = options['s']
    destination_dir = options['d']

    puts "Will package processors from #{source_dir} to #{destination_dir}"
    # find all processors in the base directory
    processor_names = Dir["#{source_dir}/*"].map do |dir|
      File.basename(dir)
    end

    # Drop files, only use directories
    processor_names.delete_if do |item|
      !File.directory?("#{source_dir}/#{item}")
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

    Eh::Settings.current.deployment_management_files.each do |file|
      FileUtils.cp(file, destination_dir)
    end

    # Zip all processors
    included_processor_names.each do |processor_name|

      directory = File.join(source_dir, processor_name) # last slash could be omitted
      zipfile_name = File.join(destination_dir, "#{processor_name}.zip")

      # remove zip before we create a new one
      FileUtils.rm zipfile_name, :force => true

      options = {"directories-recursively" => true}

      Zip::File.open(zipfile_name,Zip::File::CREATE) do |zipfile|

        [directory].each{ |file_to_be_zipped|

          if File.directory?(file_to_be_zipped)
            # should skip directories
            next if options["directories-skip"]

            # should recursively add directory
            if options["directories-recursively"]
              directory = file_to_be_zipped
              puts "zipper: archiving directory: #{directory}"
              directory_chosen_pathname = options["directories-recursively-splat"] ? directory : File.dirname(directory)
              directory_pathname = Pathname.new(directory_chosen_pathname)
              files = Dir[File.join(directory, '**', '**')]

              # pattern to exclude unwanted folders
              re = Regexp.new("^#{directory}/(log|logs|exceptions|pids|tmp)")
              files.delete_if {|filename| re.match(filename) if File.directory?(filename)}

              files.each do |file|
                file_pathname = Pathname.new(file)
                file_relative_pathname = file_pathname.relative_path_from(directory_pathname)
                zipfile.add(file_relative_pathname,file)
              end
              next
            end
          end

          filename = File.basename(file_to_be_zipped)

          puts "zipper: archiving #{file_to_be_zipped} as #{filename} into #{zipfile}"

          zipfile.add(filename,file_to_be_zipped)
        }
      end
    end

    puts "Done packaging #{included_processor_names.size} processors"
  end
end
