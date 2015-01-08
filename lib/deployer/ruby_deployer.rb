class Deployer::RubyDeployer < Deployer::BaseDeployer
  attr_reader :processor_name

  def initialize(processor_name, options)
    super(options)
    @processor_name = processor_name
  end

  def logs_dir
    File.join(base_dir, 'shared', 'logs')
  end

  def pids_dir
    File.join(base_dir, 'shared', 'pids')
  end

  def current_dir
    File.join(base_dir, 'eh-current')
  end

  def processor_dir
    File.join(current_dir, 'ruby', processor_name)
  end

  def config_source_dir
    File.join(base_dir, 'config', 'ruby', processor_name)
  end

  def deploy!
    puts "deploying #{processor_name} to #{stage.name} for environment #{stage.node_env}"
    puts "deploying via: #{deploy_via}"

    Deployer::Executor.new(stage, verbose: verbose?) do |executor|
      # create required directories
      executor.execute("mkdir -p #{base_dir} ; mkdir -p #{logs_dir} ; mkdir -p #{File.join(current_dir, 'ruby')} ; mkdir -p #{File.join(cached_copy_dir, 'ruby')}")

      if via_scp?
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
      executor.execute("if [[ -d #{config_source_dir} ]] ; then cp -r #{config_source_dir}/* #{processor_dir}; fi")

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
  end

end
