require_relative 'executor'

desc 'deploy a single processor'
arg_name 'processor_name stage'

command :deploy_processor do |c|
  c.flag([:e, :environment], desc: "environment", type: String, long_desc: "Environment in which the processor is started", default_value: 'development')

  c.action do |global_options, options, args|
    if args.size < 1
      puts "Needs at least one argument: processor_name"
      exit -1
    end

    processor_name = args[0]
    stage = args[1] || 'development'
    environment = options[:environment]

    puts "deploying #{processor_name} to #{stage} for environment #{environment}"

    base_dir = "/apps/compoundbank/s_cme/apps/event_hub"
    shared_dir = File.join(base_dir, 'shared')
    logs_dir = File.join(shared_dir, 'logs')
    pids_dir = File.join(shared_dir, 'pids')


    releases_dir = File.join(base_dir, 'eh-releases')
    current_dir = File.join(base_dir, 'eh-current')

    processor_dir = File.join(current_dir, 'ruby', processor_name)


    # TODO:
    # - checkout from svn
    # - config hosts
    # - copy config
    Executor.new('s_cme', 2222, ['localhost'], verbose: false) do |executor|
      #
      executor.execute("rm -rf #{processor_dir}")

      #
      executor.execute("mkdir -p #{base_dir}; mkdir -p #{logs_dir}")

      #
      source = "#{Eh::Settings.current.releases_dir}/ruby/#{processor_name}.zip"
      target = File.join(releases_dir, 'ruby')
      executor.upload(source, target)

      #
      source = File.join(current_dir, 'ruby')
      target = "#{File.join(releases_dir, 'ruby', processor_name)}.zip"
      executor.execute("unzip -o -d #{source} #{target}")

      #
      executor.execute("ln -s #{logs_dir} #{File.join(processor_dir, 'logs')}")

      #
      executor.execute("ln -s #{pids_dir} #{File.join(processor_dir, 'pids')}")

      #
      executor.execute("cd #{processor_dir} && bundle install --without test")

      #
      executor.execute("kill -s TERM $(cat #{File.join(pids_dir, processor_name)}.pid)", abort_on_error: false)

      #
      executor.execute("cd #{processor_dir} && bundle exec ruby #{processor_name}.rb -d --environment=#{environment}")
    end

  end
end
