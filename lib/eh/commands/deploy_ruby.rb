desc 'deploy a single ruby processor'
arg_name 'processor_name'

command :deploy_ruby do |c|
  c.flag([:s, :stage], desc: "stage", type: String, long_desc: "Stage where processor is deployed to", default_value: 'localhost')
  c.flag([:deploy_via], desc: "how to get hold of the processor: scm or scp", type: String, long_desc: "copy the processor zip file via scp from this machine or check it out from scm", default_value: 'scp')

  c.switch([:v, :verbose], :desc => "Show additional output.")

  c.action do |global_options, options, args|
    if args.size < 1
      puts "Needs at least one argument: processor_name"
      exit -1
    end

    processor_name = args[0]

    Deployer::RubyDeployer.new(processor_name, options).deploy!
  end
end
