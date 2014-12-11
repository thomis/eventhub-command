desc 'Packages Rails Console to zip file'
command :package_rails do |c|
  c.flag([:d, :destination], :desc => "Destination directory to place created zip file.", :default_value => Eh::Settings.current.rails_release_dir)
  c.flag([:s, :source], :desc => "Source directory to read rails console from.", :default_value => Eh::Settings.current.rails_src_dir)

  c.action do |global_options, options, args|
    source_dir = options['s']
    destination_dir = options['d']

    skip_files = ["#{source_dir}/config/database.yml"]

    puts "Will package rails console from #{source_dir} to #{destination_dir}"

    console = Dir["#{source_dir}"]

    FileUtils.mkdir_p(destination_dir)

    zipfile_name = File.join(destination_dir, "console.zip")
    directory = source_dir

    # remove zip before we create a new one
    FileUtils.rm zipfile_name, :force => true

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|

      #zipfile.add(processor_name, directory)
      [directory].each do |file_to_be_zipped|
        if File.directory?(file_to_be_zipped)
          # should skip directories
          next if options["directories-skip"]

          directory = file_to_be_zipped
          puts "zipper: archiving directory: #{directory}"
          directory_chosen_pathname = options["directories-recursively-splat"] ? directory : File.dirname(directory)
          directory_pathname = Pathname.new(directory_chosen_pathname)
          files = Dir[File.join(directory, '**', '**')]

          files.delete_if do |filename|
            ["#{source_dir}/log", "#{source_dir}/logs", "#{source_dir}/exceptions", "#{source_dir}/tmp"].any? do |prefix|
              filename.start_with?(prefix)
            end
          end

          files.each do |file|
            if skip_files.include? file
              puts "skipping #{file}"
              next
            end

            file_pathname = Pathname.new(file)
            file_relative_pathname = file_pathname.relative_path_from(directory_pathname)
            zipfile.add(file_relative_pathname,file)
          end

          next
        end

        filename = File.basename(file_to_be_zipped)

        puts "zipper: archiving #{file_to_be_zipped} as #{filename} into #{zipfile}"

        zipfile.add(filename,file_to_be_zipped)
      end
    end

    puts "Done packaging rails"
  end
end
