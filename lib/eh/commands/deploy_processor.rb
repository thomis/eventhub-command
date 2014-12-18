
desc 'deploy a single processor'
arg_name 'processor_name stage'

command :deploy_processor do |c|
  c.flag([:s, :stage], desc: "stage", type: String, long_desc: "Stage where processor is deployed to", default_value: 'localhost')
  c.flag([:deploy_via], desc: "how to get hold of the processor: scm or scp", type: String, long_desc: "copy the processor zip file via scp from this machine or check it out from scm", default_value: 'scp')

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


    puts "deploying #{processor_name} to #{stage.name} for environment #{stage.node_env}"
    puts "deploying via: #{options[:deploy_via]}"


    base_dir = "/apps/compoundbank/s_cme/apps/event_hub"
    logs_dir = File.join(base_dir, 'shared', 'logs')
    pids_dir = File.join(base_dir, 'shared', 'pids')


    if options[:deploy_via] == 'scp'
      cached_copy_dir = File.join(base_dir, 'eh-cached-copy-scp')
    else
      cached_copy_dir = File.join(base_dir, 'eh-cached-copy-scm')
    end

    current_dir = File.join(base_dir, 'eh-current')

    processor_dir = File.join(current_dir, 'ruby', processor_name)
    config_source_dir = File.join(base_dir, 'config', 'ruby')

    scm_username = 'deploy'
    scm_password = 'deploy2014!'
    scm_base_url = "https://whistler.plan.io/svn/eventhub"
    repository = "#{scm_base_url}/branches/master/releases"

    Deployer::Executor.new(stage, verbose: options[:verbose]) do |executor|
      # only for test purpose...
      executor.execute("rm -rf #{processor_dir}")


      # create required directories
      executor.execute("mkdir -p #{base_dir} ; mkdir -p #{logs_dir} ; mkdir -p #{File.join(current_dir, 'ruby')} ; mkdir -p #{File.join(cached_copy_dir, 'ruby')}")

      if options[:deploy_via] == 'scp'
        # upload pre-packaged processor via scp
        source = "#{Eh::Settings.current.releases_dir}/ruby/#{processor_name}.zip"
        target = File.join(cached_copy_dir, 'ruby', "#{processor_name}.zip")
        executor.upload(source, target)
      else
        co_line = "svn co --trust-server-cert --non-interactive --username #{scm_username} --password #{scm_password} #{repository} #{cached_copy_dir}"

        executor.execute(co_line)
      end

      # unzip package
      source = File.join(current_dir, 'ruby')
      target = "#{File.join(cached_copy_dir, 'ruby', processor_name)}.zip"
      executor.execute("unzip -o -d #{source} #{target}")

      # copy config
      source = File.join(config_source_dir, processor_name)
      executor.execute("if [[ -d #{source} ]] ; then cp -r #{source}/* #{processor_dir}; fi")

      # symlink log dir
      executor.execute("ln -s #{logs_dir} #{File.join(processor_dir, 'logs')}")

      # symlink pids dir
      executor.execute("ln -s #{pids_dir} #{File.join(processor_dir, 'pids')}")

      # install gems
      executor.execute("cd #{processor_dir} && bundle install --without test")

      # stop old one
      executor.execute("kill -s TERM $(cat #{File.join(pids_dir, processor_name)}.pid)", abort_on_error: false, comment: "This is not sooo important")

      # start new one
      executor.execute("cd #{processor_dir} && bundle exec ruby #{processor_name}.rb -d --environment=#{stage.node_env}")
    end
  #rescue => e
  #  p e.message
  #  p e.backtrace.join("\n")
  #end
  end
end
