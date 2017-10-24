desc 'Deployment commands'
command :deploy do |deploy|
  deploy.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where processor is deployed to', default_value: Eh::Settings.current.default_stage)
  deploy.flag([:branch], desc: 'branch', type: String, long_desc: 'What branch to deploy. Only when deploy_via=scm', default_value: 'master')
  deploy.flag([:tag], desc: 'tag', type: String, long_desc: 'What tag to deploy. Only when deploy_via=scm', default_value: nil)
  deploy.flag([:deploy_via], desc: 'where to deploy from', type: String, long_desc: 'deploy via scm or scp. If you use scp then the working_dir is packaged and copied tot the servers', default_value: 'svn')

  deploy.desc 'Deploy all components'
  deploy.command :all do |all|
    all.action do |global_options, options, args|
      forward_arguments = args.join(' ')
      deploy_config(options, forward_arguments)
      deploy_console(options, forward_arguments)
      deploy_go(options, forward_arguments)
      deploy_ruby(options, forward_arguments)
      deploy_mule(options, forward_arguments)
    end
  end

  deploy.desc 'Deploy configuration files'
  deploy.command :config do |config|
    config.action do |global_options, options, args|
      Deployer::ConfigDeployer.new(options).deploy!
    end
  end

  deploy.desc 'Deploy rails console'
  deploy.command :console do |console|
    console.flag([:working_dir], desc: 'directory to execute commands in', type: String, default_value: '.')

    console.action do |global_options, options, args|
      Deployer::ConsoleDeployer.new(options).deploy!
    end
  end

  deploy.desc 'Deploy channel adapter(s)'
  deploy.arg_name '[NAME1[,NAME2,PATTERN*]]'
  deploy.command :mule do |mule|
    mule.action do |global_options, options, args|
      if args[0]
        adapter_names = args[0].split(',').map(&:strip)
      else
        adapter_names = nil
      end
      Deployer::MuleDeployer.new(adapter_names, options).deploy!
    end
  end

  deploy.desc 'Deploy ruby processor(s)'
  deploy.arg_name '[NAME1[,NAME2,PATTERN*]]'
  deploy.command :ruby do |ruby|
    ruby.action do |global_options, options, args|
      if args[0]
        processor_names = args[0].split(',').map(&:strip)
      else
        processor_names = nil
      end
      Deployer::RubyDeployer.new(processor_names, options).deploy!
    end
  end

  deploy.desc 'Deploy go processor(s)'
  deploy.arg_name '[NAME1[,NAME2,PATTERN*]]'
  deploy.command :go do |go|
    go.action do |global_options, options, args|
      if args[0]
        processor_names = args[0].split(',').map(&:strip)
      else
        processor_names = nil
      end
      Deployer::GoDeployer.new(processor_names, options).deploy!
    end
  end

  private

  def deploy_ruby(options, forward_arguments)
    system "#{extend_command('deploy ruby')} #{copy_options(options, :stage, :branch, :tag, :verbose)} #{forward_arguments}"
  end

  def deploy_go(options, forward_arguments)
    system "#{extend_command('deploy go')} #{copy_options(options, :stage, :branch, :tag, :verbose)} #{forward_arguments}"
  end

  def deploy_console(options, forward_arguments)
    system "#{extend_command('deploy console')} #{copy_options(options, :stage)} #{forward_arguments}"
  end

  def deploy_mule(options, forward_arguments)
    system "#{extend_command('deploy mule')} #{copy_options(options, :stage, :verbose)} #{forward_arguments}"
  end

  def deploy_config(options, forward_arguments)
    system "#{extend_command('deploy config')} #{copy_options(options, :stage, :branch, :tag, :verbose)} #{forward_arguments}"
  end

  def copy_option(options, option)
    if options[option]
      "--#{option}=#{options[option]}"
    end
  end

  def copy_options(options, *selected)
    selected.map do |name|
      copy_option(options, name)
    end.compact.join(' ')
  end

  def extend_command(command)
    "eh #{command}"
  end

end
