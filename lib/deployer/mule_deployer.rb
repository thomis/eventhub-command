class Deployer::MuleDeployer < Deployer::BaseDeployer
  attr_reader :adapter_name

  def initialize(adapter_name, options)
    super(options)
    @adapter_name = adapter_name
  end

  def adapter_cached_copy
    File.join(cached_copy_dir, 'mule', "#{adapter_name}.zip")
  end

  def config_source_dir
    File.join(base_dir, 'config', 'mule', adapter_name)
  end

  def deploy!
    puts "deploying #{adapter_name} to #{stage.name} for environment #{stage.node_env}"
    puts "deploying via: #{deploy_via}"

    Deployer::Executor.new(stage, verbose: verbose?) do |executor|
      # create required directories
      executor.execute("mkdir -p #{base_dir}")
      executor.execute("rm -rf #{cached_copy_dir} && mkdir -p #{cached_copy_dir}/mule")

      if via_scp?
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
