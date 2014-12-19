
desc 'deploy a single channel adapter'
arg_name 'channel_adapter stage'

command :deploy_mule do |c|
  c.flag([:s, :stage], desc: "stage", type: String, long_desc: "Stage where channel adapter is deployed to", default_value: 'localhost')
  c.flag([:deploy_via], desc: "how to get hold of the channel adapter: scm or scp", type: String, long_desc: "copy the channel adapter zip file via scp from this machine or check it out from scm", default_value: 'scp')

  c.switch([:v, :verbose], :desc => "Show additional output.")

  c.action do |global_options, options, args|
    if args.size < 1
      puts "Needs at least one argument: channel_adapter"
      exit -1
    end

    adapter_name = args[0]


    stage_path = File.join(Eh::Settings.current.stages_dir, "#{options[:stage]}.yml")
    stage = Deployer::Stage.load(stage_path)

    puts "deploying #{adapter_name} to #{stage.name} for environment #{stage.node_env}"
    puts "deploying via: #{options[:deploy_via]}"


    base_dir = "/apps/compoundbank/s_cme/apps/event_hub"


    if options[:deploy_via] == 'scp'
      cached_copy_dir = File.join(base_dir, 'eh-cached-copy-scp')
    else
      cached_copy_dir = File.join(base_dir, 'eh-cached-copy-scm')
    end

    adapter_cached_copy = File.join(cached_copy_dir, 'mule', "#{adapter_name}.zip")
    config_source_dir = File.join(base_dir, 'config', 'mule', adapter_name)

    # TODO: move to common place for all commands
    scm_username = 'deploy'
    scm_password = 'deploy2014!'
    scm_base_url = "https://whistler.plan.io/svn/eventhub"
    repository = "#{scm_base_url}/branches/master/releases"

    Deployer::Executor.new(stage, verbose: options[:verbose]) do |executor|
      # create required directories
      executor.execute("mkdir -p #{base_dir} ; mkdir -p #{File.join(cached_copy_dir, 'mule')}")

      if options[:deploy_via] == 'scp'
        # upload pre-packaged processor via scp
        source = "#{Eh::Settings.current.releases_dir}/mule/#{adapter_name}.zip"
        raise ArgumentError, "#{adapter_name} does not seem to exist, no file to read at #{source}" if !File.readable?(source)
        executor.upload(source, adapter_cached_copy)
      else
        co_line = "svn co --trust-server-cert --non-interactive --username #{scm_username} --password #{scm_password} #{repository} #{cached_copy_dir}"
        executor.execute(co_line)
      end

      # copy config
      source = File.join(config_source_dir, adapter_name)
      executor.execute("if [[ -d #{config_source_dir} ]] ; then cd #{config_source_dir} ; zip -r #{adapter_cached_copy} . ; fi")

      # deploy
      executor.execute("cp #{adapter_cached_copy} $MULE_HOME/apps")
    end
  end
end
