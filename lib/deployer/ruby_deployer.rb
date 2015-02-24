class Deployer::RubyDeployer < Deployer::BaseDeployer
  attr_accessor :processor_names

  def initialize(processor_names, options)
    super(options)
    @processor_names = processor_names
  end

  def deploy!
    puts "deploying to #{stage.name} via #{deploy_via}".light_blue.on_blue

    Deployer::Executor.new(stage, verbose: verbose?) do |executor|
      create_base_dirs(executor)


      update_cached_copy(executor)


      # fetch processor_names unless they have been passed as an argument to the initializer
      processor_names_to_deploy = resolve_processor_names(executor, options)
      processor_names_to_deploy.each do |processor_name|
        puts
        puts "Deploying #{processor_name}".light_blue.on_blue
        log_deployment(executor, "Deploying #{processor_name} via #{deploy_via} from #{cached_copy_dir}")
        # stop old one
        executor.execute("kill -s TERM $(cat #{File.join(pids_dir, processor_name)}.pid)", abort_on_error: false, comment: "This is not sooo important")

        # unzip package
        target = deploy_dir('ruby')
        source = cached_copy_dir('ruby',"#{processor_name}.zip")
        executor.execute("rm -rf #{processor_dir(processor_name)} && unzip -o -d #{target} #{source}")

        # copy config
        executor.execute("if [[ -d #{config_source_dir(processor_name)} ]] ; then cp -r #{config_source_dir(processor_name)}/* #{processor_dir(processor_name)}; fi")

        # symlink log dir
        executor.execute("ln -s #{logs_dir} #{processor_dir(processor_name, 'logs')}")

        # symlink pids dir
        executor.execute("ln -s #{pids_dir} #{processor_dir(processor_name, 'pids')}")

        # install gems
        executor.execute("cd #{processor_dir(processor_name)} && bundle install --without test")

        # start new one
        executor.execute("cd #{processor_dir(processor_name)} && bundle exec ruby #{processor_name}.rb -d -e $EH_ENV")
      end
    end
  end

  private

  def update_cached_copy(executor)
    if via_scp?
      source = Eh::Settings.current.releases_dir('ruby', '*.zip')
      target_dir = File.join(cached_copy_dir, 'ruby')
      executor.execute("rm -rf #{target_dir}/*.zip && mkdir -p #{target_dir}")
      executor.upload(source, target_dir)
    else
      update_scm(executor)
    end
  end

  def logs_dir
    File.join(shared_dir, 'logs')
  end

  def pids_dir
    File.join(shared_dir, 'pids')
  end

  def deploy_dir(*extra_paths)
    File.join(base_dir, *extra_paths)
  end

  def processor_dir(*extra_paths)
    File.join(deploy_dir, 'ruby', *extra_paths)
  end

  def config_source_dir(processor_name)
    super('ruby', processor_name)
  end

  # Detect what processors to deploy
  #
  def resolve_processor_names(executor, options)
    available = remote_ls(executor, options, File.join(cached_copy_dir, 'ruby', '*.zip')).map do |name|
      File.basename(name, '.zip')
    end

    fetched = Array(processor_names).map do |name|
      if name.include?('*') # resolve pattern on remote machine
        remote_ls(executor, options, File.join(cached_copy_dir, 'ruby', "#{name}.zip"))
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

end
