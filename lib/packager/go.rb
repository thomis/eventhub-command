class Packager::Go

  PLATFORMS = ['linux','windows','darwin']

  def initialize(source_dir, destination_dir, include_pattern_string, exclude_pattern_string, platform)
    @source_dir = Pathname.new(source_dir)
    @destination_dir = Pathname.new(destination_dir)
    @include_pattern_string = include_pattern_string
    @exclude_pattern_string = exclude_pattern_string
    @platform = platform
  end

  def package
    assert_at_least_one_processor!
    validate_platforms!
    create_destination_dir
    build_processors
    package_processors
  end

  private

  attr_reader :source_dir, :destination_dir, :include_pattern_string, :exclude_pattern_string

  def build_processors
    puts "Build processors"
    processor_names.each do |processor_name|
      build_processor(processor_name)
    end
  end

  def build_processor(processor_name)
    print "Build: #{processor_name.light_blue}"
    system "cd #{processor_source_dir(processor_name)} && GOOS=#{@platform} GOARCH=amd64 go build"
    puts " done".green
  end

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
    # currently take only the binary and the config folder
    files = Dir.glob(File.join(processor_source_dir(processor_name), 'config', '**', '*'))
    files << File.join(processor_source_dir(processor_name),processor_name)

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

  def assert_at_least_one_processor!
    if processor_names.empty?
      raise "There are no processor names. Either your -s directory is empty or you specified a strange combination of include and exclude pattern."
    end
  end

  def validate_platforms!
    unless PLATFORMS.include?(@platform)
      raise "Given platform [#{@platform}] is not allowed out of [#{PLATFORMS.join(', ')}]"
    end
  end

  def processor_names
    included_names = existing_processor_names
    included_names = included_processor_names(included_names)
    excluded_names  = excluded_processor_names(included_names)
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
