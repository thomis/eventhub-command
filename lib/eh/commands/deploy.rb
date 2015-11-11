desc 'deployment'

command :deploy do |c|
  c.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where processor is deployed to', default_value: Eh::Settings.current.default_stage)
  c.flag([:branch], desc: 'branch', type: String, long_desc: 'What branch to deploy. Only when deploy_via=scm', default_value: 'master')
  c.flag([:tag], desc: 'tag', type: String, long_desc: 'What tag to deploy. Only when deploy_via=scm', default_value: nil)

  c.command :all do |c|

    c.action do |global_options, options, arguments|
      forward_arguments = arguments.join(' ')
      deploy_config(options, forward_arguments)
      deploy_ruby(options, forward_arguments)
      deploy_mule(options, forward_arguments)
      deploy_console(options, forward_arguments)
    end
  end


  private

  def deploy_ruby(options, forward_arguments)
    system "#{extend_command(:deploy_ruby)} #{copy_options(options, :stage, :branch, :tag, :verbose)} #{forward_arguments}"
  end

  def deploy_console(options, forward_arguments)
    Bundler.with_clean_env do
      Dir.chdir(console_dir) do
        system "bundle install && cap #{options[:stage]} deploy"
      end
    end
  end

  def deploy_mule(options, forward_arguments)
    system "#{extend_command(:deploy_mule)} #{copy_options(options, :stage, :verbose)} #{forward_arguments}"
  end

  def deploy_config(options, forward_arguments)
    system "#{extend_command(:deploy_config)} #{copy_options(options, :stage, :branch, :tag, :verbose)} #{forward_arguments}"
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
    "bundle exec eh #{command}"
  end

  def console_dir
    Eh::Settings.current.console_source_dir
  end
end
