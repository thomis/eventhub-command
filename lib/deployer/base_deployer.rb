class Deployer::BaseDeployer
  attr_reader :options, :stage_path, :stage

  def initialize(options)
    @options = options

    @stage_path = File.join(Eh::Settings.current.stages_dir, "#{options[:stage]}.yml")
    @stage = Deployer::Stage.load(stage_path)
  end

  private

  def log_deployment(executor, message)
    executor.execute("echo $(date): #{message} - #{ENV['USER']} >> #{deploy_log_file}")
  end

  def base_dir
    "/apps/compoundbank/s_cme/apps/event_hub"
  end

  def deploy_log_file
    File.join(base_dir, 'deploy.log')
  end

  def deploy_via
    options[:deploy_via]
  end

  def verbose?
    options[:verbose]
  end

  def via_scp?
    deploy_via == 'scp'
  end

  def cached_copy_dir
    if via_scp?
      File.join(base_dir, 'eh-cached-copy-scp')
    else
      if options[:tag]
        File.join(base_dir, 'eh-cached-copy-svn', 'tags', options[:tag], 'releases')
      elsif options[:branch]
        File.join(base_dir, 'eh-cached-copy-svn', 'branches', options[:branch], 'releases')
      else
        File.join(base_dir, 'eh-cached-copy-svn', 'branches', 'master', 'releases')
      end
    end
  end

  def scm_username
    'deploy'
  end

  def scm_password
    'deploy2014!'
  end

  def scm_base_url
    "https://whistler.plan.io/svn/eventhub"
  end

  def repository
    "#{scm_base_url}/branches/master/releases"
  end

  def update_scm(executor)
    dir = File.join(base_dir, 'eh-cached-copy-svn')
    cmd = <<-EOS
      if [[ -d #{dir} ]]
      then
        cd #{dir}
        svn up --trust-server-cert --non-interactive --username #{scm_username} --password #{scm_password}
      else
        svn co --trust-server-cert --non-interactive --username #{scm_username} --password #{scm_password} #{scm_base_url} #{dir}
      fi
    EOS
    executor.execute(cmd)
  end

end
