class Deployer::ConfigDeployer < Deployer::BaseDeployer
  def initialize(options = {})
    options[:deploy_via] = "svn"
    super(options)
  end

  def deploy!
    puts "deploying to #{stage.name} via #{deploy_via}".light_blue.on_blue
    Deployer::Executor.new(stage, verbose: verbose?) do |executor|
      create_base_dirs(executor)
      update_scm(executor)

      source = cached_copy_dir("..", "config", "%{stagename}", "%{hostname}", "")
      target = config_source_dir

      cmd = "rsync -r --exclude=.svn #{source} #{target}"
      executor.execute_later(cmd)
      executor.execute_batch
    end
  end
end
