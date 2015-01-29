desc 'distribute the configs to the nodes'

command :deploy_config do |c|
  c.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where processor is deployed to', default_value: 'localhost')
  c.flag([:branch], desc: 'branch', type: String, long_desc: 'What branch to deploy. Only when deploy_via=scm', default_value: 'master')
  c.flag([:tag], desc: 'tag', type: String, long_desc: 'What tag to deploy. Only when deploy_via=scm', default_value: nil)

  c.switch([:v, :verbose], :desc => 'Show additional output.')

  c.action do |global_options, options, args|
    begin
      Deployer::ConfigDeployer.new(options).deploy!
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
    end
  end
end
