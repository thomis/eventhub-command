class Deployer::ConsoleDeployer < Deployer::BaseDeployer

  def deploy!
    case deploy_via
    when 'scp' then deploy_via_scp
    when 'svn' then deploy_via_svn
    else raise "Unknown value for deploy_via: #{deploy_via}"
    end
  end

  private

  def working_dir
    options[:working_dir]
  end

  def deploy_via_scp
    cmd = "cd #{working_dir} && bundle install && bundle exec cap #{stage.name} deploy"
    execute_in_clean_env(cmd)
  end

  def deploy_via_svn
    console_release_zip = '~/apps/event_hub/shared/cached_copy_svn/branches/master/releases/rails/console.zip'
    cmds = []
    cmds << "rm -rf /tmp/console_deployment && mkdir -p /tmp/console_deployment"
    cmds << "cd /tmp/console_deployment && unzip #{console_release_zip} -d ."
    cmds << "cd /tmp/console_deployment/console && bundle install && bundle exec cap #{stage.name} deploy"
    # run the command only on one host of this stage.
    Deployer::Executor.new(stage.single_host_stage, verbose: verbose?) do |executor|
      update_scm(executor)
      cmds.each do |cmd|
        executor.execute(cmd)
      end
    end
  end

  def execute_in_clean_env(cmd)
    puts "Will run #{cmd} on your local machine"
    Bundler.with_clean_env do
      system cmd
    end
  end


end
