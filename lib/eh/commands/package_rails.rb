desc 'Packages processors to zip files'
command :package_rails do |c|
  c.flag([:d, :destination], :desc => "Destination directory to place created zip files.", :default_value => Eh::Settings.current.rails_release_dir)
  c.flag([:s, :source], :desc => "Source directory to read rails apps from.", :default_value => Eh::Settings.current.rails_src_dir)

  c.action do |global_options, options, args|
    files_and_dirs = %w{Capfile Gemfile Gemfile.lock README.rdoc Rakefile app bin db lib public spec vendor}
    source = options[:source]

    dirs = Dir.glob("#{source}")
    dirs.each do |dir|
      app = File.basename(dir)
      destination = File.join(options[:d], "#{app}.zip")
      included = files_and_dirs.map do |s|
        File.join(app, s)
      end.join(' ')
      cmd = "cd #{File.join(dir, '..')} && zip -r #{destination} #{included}"
      ret = system cmd
      puts "Packaged #{app}: #{ret}"
    end
  end

end
