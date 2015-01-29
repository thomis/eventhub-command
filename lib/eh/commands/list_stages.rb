desc 'list the available stages'

command :list_stages do |c|
  #c.flag([:branch], desc: 'branch', type: String, long_desc: 'What branch to deploy. Only when deploy_via=scm', default_value: 'master')
  #c.flag([:tag], desc: 'tag', type: String, long_desc: 'What tag to deploy. Only when deploy_via=scm', default_value: nil)

  c.switch([:v, :verbose], :desc => 'Show additional output.')

  c.action do |global_options, options, args|
    dir = Eh::Settings.current.stages_dir
    puts "Checking in #{dir}".green if options[:verbose]
    puts "Available stages are:".blue
    Dir.glob(File.join(dir, '*.yml')) do |name|
      puts "#{File.basename(name, '.*')}".light_blue
    end
  end
end
