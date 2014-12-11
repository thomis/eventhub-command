
desc 'deploy a single processor'
arg_name 'processor_name stage'

command :deploy_processor do |c|
  c.flag([:e, :environment], desc: "environment", type: String, long_desc: "Environment in which the processor is started", default_value: 'development')
  c.flag([:s, :stage], desc: "stage", type: String, long_desc: "Stage where processor is deployed to", default_value: 'localhost')
  c.switch([:v, :verbose], :desc => "Show additional output.")

  c.action do |global_options, options, args|
    #begin
    if args.size < 1
      puts "Needs at least one argument: processor_name"
      exit -1
    end

    processor_name = args[0]
    stage = args[1] || 'development'

    stage = Deployer::Stage.load("lib/stages/#{options[:stage]}.yml")

    environment = options[:environment]

    puts "deploying #{processor_name} to #{stage.name} for environment #{environment}"

    base_dir = "/apps/compoundbank/s_cme/apps/event_hub"
    shared_dir = File.join(base_dir, 'shared')
    logs_dir = File.join(shared_dir, 'logs')
    pids_dir = File.join(shared_dir, 'pids')


    releases_dir = File.join(base_dir, 'eh-releases')
    current_dir = File.join(base_dir, 'eh-current')

    processor_dir = File.join(current_dir, 'ruby', processor_name)
    config_source_dir = File.join(base_dir, 'config', 'ruby')

    # TODO:
    # - checkout from svn
    # - copy config
    Deployer::Executor.new(stage, verbose: options[:verbose]) do |executor|
      # only for test purpose...
      executor.execute("rm -rf #{processor_dir}")

      # create required directories
      executor.execute("mkdir -p #{base_dir}; mkdir -p #{logs_dir}")

      # if scp
      # upload pre-packaged processor via scp
      source = "#{Eh::Settings.current.releases_dir}/ruby/#{processor_name}.zip"
      target = File.join(releases_dir, 'ruby')
      executor.upload(source, target)
      # else
      #  chckout via svn
      # end
      # unzip package
      source = File.join(current_dir, 'ruby')
      target = "#{File.join(releases_dir, 'ruby', processor_name)}.zip"
      executor.execute("unzip -o -d #{source} #{target}")

      # copy config
      #
      #source = File.join(config_source_dir, processor_name)
      #executor.execute("if [-d #{source}]")

      # symlink log dir
      executor.execute("ln -s #{logs_dir} #{File.join(processor_dir, 'logs')}")

      # symlink pids dir
      executor.execute("ln -s #{pids_dir} #{File.join(processor_dir, 'pids')}")

      # install gems
      executor.execute("cd #{processor_dir} && bundle install --without test")

      # stop old one
      executor.execute("kill -s TERM $(cat #{File.join(pids_dir, processor_name)}.pid)", abort_on_error: false)

      # start new one
      executor.execute("cd #{processor_dir} && bundle exec ruby #{processor_name}.rb -d --environment=#{environment}")
    end
  #rescue => e
  #  p e.message
  #  p e.backtrace.join("\n")
  #end
  end
end
