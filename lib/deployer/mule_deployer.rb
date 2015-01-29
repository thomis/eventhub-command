class Deployer::MuleDeployer < Deployer::BaseDeployer
  attr_reader :adapter_names

  def initialize(adapter_names, options)
    super(options)
    @adapter_names = adapter_names
  end

  def adapter_cached_copy(adapter_name)
    cached_copy_dir('mule', "#{adapter_name}.zip")
  end

  def config_source_dir(adapter_name)
    super('mule', adapter_name)
  end

  def deploy!
    puts "deploying to #{stage.name} for environment #{stage.node_env} via #{deploy_via}".light_blue.on_blue

    Deployer::Executor.new(stage, verbose: verbose?) do |executor|
      create_base_dirs(executor)

      # update
      update_cached_copy(executor)

      adapter_names_to_deploy = resolve_adapter_names(executor, options)

      adapter_names_to_deploy.each do |adapter_name|
        puts
        puts "Deploying #{adapter_name}".light_blue.on_blue
        log_deployment(executor, "Deploying #{adapter_name} via #{deploy_via} from #{cached_copy_dir}")
        # make a copy of the zip files to merge them with config
        cached_copy_source = adapter_cached_copy(adapter_name)
        configuration_target = File.join(base_dir, 'mule', "#{adapter_name}.zip")
        executor.execute("cp #{cached_copy_source} #{configuration_target}")

        # copy config
        config_source = config_source_dir(adapter_name)
        executor.execute("if [[ -d #{config_source} ]] ; then cd #{config_source} ; zip -r #{configuration_target} . ; fi")

        # deploy
        executor.execute("cp #{adapter_cached_copy(adapter_name)} $MULE_HOME/apps")
      end
    end
  end


  private

  def resolve_adapter_names(executor, options)
    available = remote_ls(executor, options, cached_copy_dir('mule', '*.zip')).map do |name|
      File.basename(name, '.zip')
    end

    fetched = Array(adapter_names).map do |name|
      if name.include?('*') # resolve pattern on remote machine
        remote_ls(executor, options, cached_copy_dir('mule', "#{name}.zip"))
      else
        name
      end
    end
    if fetched.empty? # then fetch all
      fetched = available
    end

    fetched = fetched.flatten.map do |name|
      File.basename(name, '.zip')
    end

    verify_deployment_list!(fetched, available)

    fetched
  end

  def update_cached_copy(executor)
    if via_scp?
      source = Eh::Settings.current.releases_dir('mule', '*.zip')
      target_dir = cached_copy_dir('mule')
      executor.execute("rm -rf #{target_dir}/*.zip && mkdir -p #{target_dir}")
      executor.upload(source, target_dir)
    else
      update_scm(executor)
    end
  end
end
