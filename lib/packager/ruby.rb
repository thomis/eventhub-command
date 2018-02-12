class Packager::Ruby
  def initialize(source_dir, destination_dir, include_pattern_string, exclude_pattern_string)
    @source_dir = Pathname.new(source_dir)
    @destination_dir = Pathname.new(destination_dir)
    @include_pattern_string = include_pattern_string
    @exclude_pattern_string = exclude_pattern_string
  end

  def package
    assert_at_least_one_processor!
    create_destination_dir
    copy_deployment_management_files
    package_processors
  end

  private

  attr_reader :source_dir, :destination_dir, :include_pattern_string, :exclude_pattern_string

  def package_processors
    puts "Start packaging"
    processor_names.each do |processor_name|
      package_processor(processor_name)
    end
    puts "Done packaging #{processor_names.size} processors".green
  end

  def package_processor(processor_name)
    print "Package: #{processor_name.light_blue} "
    remove_destination_file(processor_name)

    Zip::File.open(destination_file_name(processor_name), Zip::File::CREATE) do |zipfile|
      files = files_to_zip(processor_name)
      files.each do |file|
        relative_filename = file.relative_path_from(source_dir)
        zipfile.add(relative_filename, file)
      end
    end
    puts " done".green
  end


  def files_to_zip(processor_name)
    exclude_directories = %w{logs/ log/ exceptions/ pids/ tmp/}
    files = Dir.glob(File.join(processor_source_dir(processor_name), '**', '{*,.ruby-version}')).select do |name|
      exclude_directories.none? do |exclude|
        prefix = File.join(processor_source_dir(processor_name), exclude)
        name.start_with?(prefix)
      end
    end
    files.map do |file|
      Pathname.new(file)
    end
  end

  def processor_source_dir(processor_name)
    File.join(source_dir, processor_name)
  end

  def create_destination_dir
    FileUtils.mkdir_p(destination_dir)
  end

  def remove_destination_file(processor_name)
    FileUtils.rm destination_file_name(processor_name), force: true
  end

  def destination_file_name(processor_name)
    File.join(destination_dir, "#{processor_name}.zip")
  end

  def copy_deployment_management_files
    Eh::Settings.current.deployment_management_files.each do |file|
      FileUtils.cp(file, destination_dir)
    end
  end

  def assert_at_least_one_processor!
    if processor_names.empty?
      raise "There are no processor names. Either your -s directory is empty or you specified a strange combination of include and exclude pattern."
    end
  end

  def processor_names
    included_names = existing_processor_names
    included_names = included_processor_names(included_names)
    excluded_names = excluded_processor_names(included_names)
    included_names - excluded_names
  end

  def existing_processor_names
    Dir["#{source_dir}/*"].map do |dir|
      File.basename(dir)
    end.delete_if do |item|
      !File.directory?("#{source_dir}/#{item}")
    end.sort
  end

  def included_processor_names(names)
    # if processor names are given as arguments then use them.
    # can contain wildcards like "console.*" to include all processors
    # starting with "console.".
    names.select do |name|
      include_patterns.empty? || include_patterns.any? do |pattern|
        wildcard_pattern_match?(pattern, name) || pattern_match?(pattern, name)
      end
    end
  end

  def excluded_processor_names(names)
    names.select do |name|
      exclude_patterns.any? && exclude_patterns.any? do |pattern|
        wildcard_pattern_match?(pattern, name) || pattern_match?(pattern, name)
      end
    end
  end

  def include_patterns
    (include_pattern_string || '').split(',').map { |part| part.strip }
  end

  def exclude_patterns
    (exclude_pattern_string || '').split(',').map { |part| part.strip }
  end

  def wildcard_pattern?(pattern)
    pattern.end_with?('*')
  end

  def wildcard_pattern_match?(pattern, name)
    wildcard_pattern?(pattern) && name.start_with?(pattern.gsub('*', ''))
  end

  def pattern_match?(pattern, name)
    pattern == name
  end
end
