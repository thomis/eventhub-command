desc 'deploy a single ruby processor'
arg_name '[processor_name,[other_processor_name,pattern*]]'

command :deploy_ruby do |c|
  c.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where processor is deployed to', default_value: 'development')
  c.flag([:deploy_via], desc: 'how to get hold of the processor: scm or scp', type: String, long_desc: 'copy the processor zip file via scp from this machine or check it out from scm', default_value: 'scp')
  c.flag([:branch], desc: 'branch', type: String, long_desc: 'What branch to deploy. Only when deploy_via=scm', default_value: 'master')
  c.flag([:tag], desc: 'tag', type: String, long_desc: 'What tag to deploy. Only when deploy_via=scm', default_value: nil)

  c.switch([:v, :verbose], :desc => 'Show additional output.')

  c.action do |global_options, options, args|
    begin
      if args[0]
        processor_names = args[0].split(',').map(&:strip)
      else
        processor_names = nil
      end
      Deployer::RubyDeployer.new(processor_names, options).deploy!
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
    end
  end
end
