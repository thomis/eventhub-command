desc 'Generate template for a new processor'
command :generate do |c|

  c.arg_name 'MODULE_NAME PROCESSOR_NAME'
  c.desc "Generate ruby based processor"
  c.command :ruby do |c|
    c.action do |global_options, options, args|
      require 'active_support/core_ext/string/inflections'
      require 'fileutils'
      require 'erb'

      if args.size != 2
        puts "Needs exactly 2 arguments: eh generate processor MODULE NAME"
        exit -1
      end

      processor_module_name = args[0].camelcase
      processor_class_name = args[1].camelcase
      underscored_processor_module_name = processor_module_name.underscore
      underscored_processor_class_name = processor_class_name.underscore

      destination_dir = Eh::Settings.current.ruby_processors_src_dir
      destination_dir = File.join(destination_dir, "#{underscored_processor_module_name}.#{underscored_processor_class_name}")

      if Dir.exists? destination_dir
        puts "#{destination_dir} already exists!"
        exit -1
      end

      template_tmp_dir = Eh::Settings.current.template_tmp_dir
      checkout_git_repo(template_tmp_dir)

      FileUtils.cp_r template_tmp_dir, destination_dir
      FileUtils.rm_rf File.join(destination_dir, ".git")
      FileUtils.rm File.join(destination_dir, 'README.md')

      puts "Generating processor #{processor_module_name}::#{processor_class_name} in #{destination_dir}"
      Dir.glob(destination_dir + "/**/*.erb") do |file|
        template = ERB.new(File.read(file))

        File.open(file, "w") do |writeable_file|
          writeable_file.puts template.result(binding)
        end

        FileUtils.mv file, File.join(File.dirname(file), File.basename(file, ".erb"))
      end

      replacements = [
        ["underscored_processor_module_name", underscored_processor_module_name],
        ["underscored_processor_class_name", underscored_processor_class_name],
        ["processor_module_name", processor_module_name],
        ["processor_class_name", processor_class_name]
      ]

      rename_files_with_replacements(destination_dir, replacements)

      FileUtils.rm_rf template_tmp_dir

      puts "Done."
    end
  end

  def shallow_clone_git_repository(source_url, destination_dir)
    system("git clone --depth 1 #{source_url} #{destination_dir}")
  end

  def rename_files_with_replacements(destination_dir, replacements)
    Dir.glob(destination_dir + "/**/*") do |src_file_path|
      if File.file? src_file_path
        dir = File.dirname src_file_path
        file_with_replacements = File.basename src_file_path

        replacements.each do |find_string, replace_string|
          file_with_replacements.sub!(find_string, replace_string)
        end

        dest_file_path = File.join(dir, file_with_replacements)

        if src_file_path != dest_file_path
          FileUtils.mv src_file_path, dest_file_path
        end
      end
    end
  end

  def checkout_git_repo(destination_dir)
    template_repository_url = Eh::Settings.current.processor_template_repository_url
    puts "Checking out latest template from #{template_repository_url}"
    FileUtils.rm_rf(destination_dir)
    FileUtils.mkdir(destination_dir)
    shallow_clone_git_repository(template_repository_url, destination_dir)
  end
end
