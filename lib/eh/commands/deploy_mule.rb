desc 'deploy a single channel adapter'
arg_name '[channel_adapter[,other_channel_adapter,pattern*]]'

command :deploy_mule do |c|
  c.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where channel adapter is deployed to', default_value: 'development')
  c.flag([:deploy_via], desc: 'how to get hold of the channel adapter: scm or scp', type: String, long_desc: 'copy the channel adapter zip file via scp from this machine or check it out from scm', default_value: 'svn')

  c.switch([:v, :verbose], :desc => 'Show additional output.')

  c.action do |global_options, options, args|
    begin
      if args[0]
        adapter_names = args[0].split(',').map(&:strip)
      else
        adapter_names = nil
      end
      Deployer::MuleDeployer.new(adapter_names, options).deploy!
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
    end
  end
end
