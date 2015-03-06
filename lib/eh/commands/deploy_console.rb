desc 'deploy the console rails app'

command :deploy_console do |c|
  c.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where processor is deployed to', default_value: Eh::Settings.current.default_stage)
  c.flag([:branch], desc: 'branch', type: String, long_desc: 'What branch to deploy. Only when deploy_via=scm', default_value: 'master')
  c.flag([:tag], desc: 'tag', type: String, long_desc: 'What tag to deploy. Only when deploy_via=scm', default_value: nil)
  c.flag([:deploy_via], desc: 'where to deploy from', type: String, long_desc: 'deploy via scm or scp. If you use scp then the working_dir is packaged and copied tot the servers', default_value: 'svn')
  c.flag([:working_dir], desc: 'directory to execute commands in', type: String, default_value: '.')
  c.switch([:v, :verbose], :desc => 'Show additional output.')

  c.action do |global_options, options, args|
    Deployer::ConsoleDeployer.new(options).deploy!
  end
end
