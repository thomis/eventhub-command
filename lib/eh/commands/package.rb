desc 'package commands'
command :package do |c|
  c.flag([:s, :source], :desc => "Source directory to read processors from.")
  c.flag([:d, :destination], :desc => "Destination directory to place created zip files.")

  c.desc 'Packages ruby processors to zip files'
  c.arg_name '[processor_name,[other_processor_name,pattern*]]'
  c.command :ruby do |ruby|
    ruby.flag([:i, :include], :desc => "Include processors by name format: [processor_name,[other_processor_name,pattern*]]", :type => String, :long_desc => "You can specify multiple processors by providing a comma-separated list as well as pattern using '*'")
    ruby.flag([:x, :exclude], :desc => "Exclude processors by name format: [processor_name,[other_processor_name,pattern*]]", :type => String, :long_desc => "You can specify multiple processors by providing a comma-separated list as well as pattern using '*'")

    ruby.action do |global_options, options, args|
      options['s'] ||= Eh::Settings.current.ruby_processors_src_dir
      options['d'] ||= Eh::Settings.current.ruby_release_dir
      source_dir = options.fetch('s')
      destination_dir = options.fetch('d')
      include_pattern = options['i'] || args[0]
      exclude_pattern = options['x']
      packager = Packager::Ruby.new(source_dir, destination_dir, include_pattern, exclude_pattern)
      packager.package
    end
  end

  c.desc 'Packages go processors to zip files'
  c.command :go do |go|

    go.flag([:p, :platform], :desc => "Define target platform [linux, osx, window]")

    go.action do |global_options, options, args|
      options['s'] ||= Eh::Settings.current.go_processors_src_dir
      options['d'] ||= Eh::Settings.current.go_release_dir
      source_dir = options.fetch('s')
      destination_dir = options.fetch('d')
      include_pattern = options['i'] || args[0]
      exclude_pattern = options['x']
      platform = options['p'] || 'linux'
      packager = Packager::Go.new(source_dir, destination_dir, include_pattern, exclude_pattern, platform)
      packager.package
    end

  end

  c.desc 'Packages rails console app to zip file'
  c.command :rails do |rails|
    rails.action do |global_options, options, args|
      options['s'] ||= Eh::Settings.current.rails_src_dir
      options['d'] ||= Eh::Settings.current.rails_release_dir
      source_dir = options.fetch('s')
      destination_dir = options.fetch('d')

      packager = Packager::Rails.new(source_dir, destination_dir)
      packager.package
    end
  end

end
