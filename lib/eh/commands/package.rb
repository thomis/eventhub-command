desc 'package commands'
command :package do |c|
  c.flag([:s, :source], :desc => "Source directory to read processors from.")
  c.flag([:d, :destination], :desc => "Destination directory to place created zip files.")

  c.desc 'Packages processors to zip files. '
  c.arg_name '[processor_name,[other_processor_name,pattern*]]'
  c.command :ruby do |c|
    c.flag([:i, :include], :desc => "Include processors by name format: [processor_name,[other_processor_name,pattern*]]", :type => String, :long_desc => "You can specify multiple processors by providing a comma-separated list as well as pattern using '*'")
    c.flag([:x, :exclude], :desc => "Exclude processors by name format: [processor_name,[other_processor_name,pattern*]]", :type => String, :long_desc => "You can specify multiple processors by providing a comma-separated list as well as pattern using '*'")

    c.action do |global_options, options, args|
      options['s'] ||= Eh::Settings.current.processors_src_dir
      options['d'] ||= Eh::Settings.current.ruby_release_dir
      source_dir = options.fetch('s')
      destination_dir = options.fetch('d')
      include_pattern = options['i']
      exclude_pattern = options['x']
      packager = Packager::Ruby.new(source_dir, destination_dir, include_pattern, exclude_pattern)
      packager.package
    end
  end


  c.command :rails do |c|
    c.action do |global_options, options, args|
      options['s'] ||= Eh::Settings.current.rails_src_dir
      options['d'] ||= Eh::Settings.current.rails_release_dir
      source_dir = options.fetch('s')
      destination_dir = options.fetch('d')

      packager = Packager::Rails.new(source_dir, destination_dir)
      packager.package
    end
  end

end
