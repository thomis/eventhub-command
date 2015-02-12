class Deployer::ConfigDeployer < Deployer::BaseDeployer
  def initialize(options = {})
    options[:deploy_via] = 'svn'
    super(options)
  end

  def deploy!
    puts "deploying to #{stage.name} via #{deploy_via}".light_blue.on_blue
    Deployer::Executor.new(stage, verbose: verbose?) do |executor|
      create_base_dirs(executor)
      update_scm(executor)

      source = cached_copy_dir('..', 'config', "%{stagename}", "%{hostname}", '')
      target = config_source_dir

      cmd = "rsync -r --exclude=.svn #{source} #{target}"
      executor.execute(cmd)
      # stage.hosts.each do |host|
      #   hostname = host[:host]
      #   source = cached_copy_dir('..', 'config', stage.name, hostname, '')
      #   target = config_source_dir

      #   # we use rsync to copy without .svn folders
      #   cmd = "mkdir -p #{target} && rsync -r --exclude=.svn #{source} #{target}"
      #   executor.execute_on(host, cmd)
      # end
    end
  end
end
