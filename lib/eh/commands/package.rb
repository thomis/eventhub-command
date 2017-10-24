desc 'Package commands'
command :package do |package|
  package.flag([:s, :source], :desc => "Source directory to read processors from.")
  package.flag([:d, :destination], :desc => "Destination directory to place created zip files.")
  package.flag([:x, :exclude], arg_name: 'NAME1,NAME2,PATTERN*', desc: "Exclude components with NAME1,NAME2,PATTERN*", type: String)

  package.desc 'Packages ruby processors to zip files'
  package.arg_name '[NAME1,[NAME2,PATTERN*]]'
  package.command :ruby do |ruby|

    ruby.action do |global_options, options, args|
      options['s'] ||= Eh::Settings.current.ruby_processors_src_dir
      options['d'] ||= Eh::Settings.current.ruby_release_dir
      source_dir = options.fetch('s')
      destination_dir = options.fetch('d')
      include_pattern = args[0]
      exclude_pattern = options['x']
      packager = Packager::Ruby.new(source_dir, destination_dir, include_pattern, exclude_pattern)
      packager.package
    end
  end

  package.desc 'Packages go processors to zip files'
  package.arg_name '[NAME1,[NAME2,PATTERN*]]'
  package.command :go do |go|
    go.flag([:p, :platform], arg_name: 'PLATFORM', desc: 'Target platform', must_match: ['linux', 'darwin', 'windows'], default_value: 'linux')

    go.action do |global_options, options, args|
      options['s'] ||= Eh::Settings.current.go_processors_src_dir
      options['d'] ||= Eh::Settings.current.go_release_dir
      source_dir = options.fetch('s')
      destination_dir = options.fetch('d')
      include_pattern = args[0]
      exclude_pattern = options['x']
      platform = options['p'] || 'linux'
      packager = Packager::Go.new(source_dir, destination_dir, include_pattern, exclude_pattern, platform)
      packager.package
    end

  end

  package.desc 'Packages rails console app to zip file'
  package.command :rails do |rails|
    rails.action do |global_options, options, args|
      options['s'] ||= Eh::Settings.current.rails_src_dir
      options['d'] ||= Eh::Settings.current.rails_release_dir

      raise 'Flag [-x, --exclude] is currently not supported with rails subcommand' if options[:exclude]

      source_dir = options.fetch('s')
      destination_dir = options.fetch('d')

      packager = Packager::Rails.new(source_dir, destination_dir)
      packager.package
    end
  end

end
