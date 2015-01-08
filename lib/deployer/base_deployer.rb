class Deployer::BaseDeployer
  attr_reader :options, :stage_path, :stage, :cached_copy_dir

  def initialize(options)
    @options = options

    @stage_path = File.join(Eh::Settings.current.stages_dir, "#{options[:stage]}.yml")
    @stage = Deployer::Stage.load(stage_path)

    if via_scp?
      @cached_copy_dir = File.join(base_dir, 'eh-cached-copy-scp')
    else
      @cached_copy_dir = File.join(base_dir, 'eh-cached-copy-scm')
    end
  end

  def base_dir
    "/apps/compoundbank/s_cme/apps/event_hub"
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
end
