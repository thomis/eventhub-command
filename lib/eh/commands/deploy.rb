desc 'deployment commands'
command :deploy do |c|
  c.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where processor is deployed to', default_value: Eh::Settings.current.default_stage)
  c.flag([:branch], desc: 'branch', type: String, long_desc: 'What branch to deploy. Only when deploy_via=scm', default_value: 'master')
  c.flag([:tag], desc: 'tag', type: String, long_desc: 'What tag to deploy. Only when deploy_via=scm', default_value: nil)
  c.switch([:v, :verbose], :desc => 'Show additional output.')
  c.flag([:deploy_via], desc: 'where to deploy from', type: String, long_desc: 'deploy via scm or scp. If you use scp then the working_dir is packaged and copied tot the servers', default_value: 'svn')
  c.switch([:i, :inspector], desc: 'start/stop via inspector')

  c.desc 'deploy all'
  c.command :all do |c|
    c.action do |global_options, options, arguments|
      forward_arguments = arguments.join(' ')
      deploy_config(options, forward_arguments)
      deploy_go(options, forward_arguments)
      deploy_ruby(options, forward_arguments)
      deploy_mule(options, forward_arguments)
      deploy_console(options, forward_arguments)
    end
  end

  c.desc 'distribute the configs to the nodes'
  c.command :config do |c|
    c.action do |global_options, options, args|
      Deployer::ConfigDeployer.new(options).deploy!
    end
  end

  c.desc 'deploy the rails console app'
  c.command :console do |c|
    c.flag([:working_dir], desc: 'directory to execute commands in', type: String, default_value: '.')

    c.action do |global_options, options, args|
      Deployer::ConsoleDeployer.new(options).deploy!
    end
  end

  c.desc 'deploy a single channel adapter'
  c.arg_name '[channel_adapter[,other_channel_adapter,pattern*]]'
  c.command :mule do |c|
    c.action do |global_options, options, args|
      if args[0]
        adapter_names = args[0].split(',').map(&:strip)
      else
        adapter_names = nil
      end
      Deployer::MuleDeployer.new(adapter_names, options).deploy!
    end
  end

  c.desc 'deploy a single ruby processor'
  c.arg_name '[processor_name,[other_processor_name,pattern*]]'
  c.command :ruby do |c|
    c.action do |global_options, options, args|
      if args[0]
        processor_names = args[0].split(',').map(&:strip)
      else
        processor_names = nil
      end
      Deployer::RubyDeployer.new(processor_names, options).deploy!
    end
  end

  c.desc 'deploy a single go processor'
  c.arg_name '[processor_name,[other_processor_name,pattern*]]'
  c.command :go do |go|
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
    system "#{extend_command('deploy ruby')} #{'-i' if options['i']} #{copy_options(options, :stage, :branch, :tag, :verbose)} #{forward_arguments}"
  end

  def deploy_go(options, forward_arguments)
    system "#{extend_command('deploy go')} #{'-i' if options['i']} #{copy_options(options, :stage, :branch, :tag, :verbose)} #{forward_arguments}"
  end

  def deploy_console(options, forward_arguments)
    system "#{extend_command('deploy console')} #{copy_options(options, :stage)} #{forward_arguments}"
  end

  def deploy_mule(options, forward_arguments)
    system "#{extend_command(:deploy_mule)} #{copy_options(options, :stage, :verbose)} #{forward_arguments}"
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
