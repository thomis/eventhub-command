desc 'deploy a single channel adapter'
arg_name 'channel_adapter'

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

    Deployer::MuleDeployer.new(adapter_name, options).deploy!
  end
end
