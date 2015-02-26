class Deployer::BaseDeployer
  attr_reader :options, :stage_path, :stage

  def initialize(options)
    @options = options

    @stage_path = File.join(Eh::Settings.current.stages_dir, "#{options[:stage]}.yml")
    @stage = Deployer::Stage.load(options[:stage], stage_path)
  end

  private

  def config_source_dir(*extra_paths)
    File.join(base_dir, 'config', *extra_paths)
  end

  def log_deployment(executor, message)
    executor.execute("echo $(date): #{message} - #{ENV['USER']} >> #{deploy_log_file}")
  end

  def base_dir
    "/apps/compoundbank/s_cme/apps/event_hub"
  end

  def deploy_log_file
    File.join(shared_dir, 'logs', 'deploy.log')
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

  def shared_dir
    File.join(base_dir, 'shared')
  end

  def cached_copy_scp_dir
    File.join(shared_dir, 'cached_copy_scp')
  end

  def cached_copy_svn_dir
    File.join(shared_dir, 'cached_copy_svn')
  end

  def cached_copy_dir(*extra_paths)
    dir = if via_scp?
      cached_copy_scp_dir
    else
      if options[:tag]
        File.join(cached_copy_svn_dir, 'tags', options[:tag], 'releases')
      elsif options[:branch]
        File.join(cached_copy_svn_dir, 'branches', options[:branch], 'releases')
      else
        File.join(cached_copy_svn_dir, 'branches', 'master', 'releases')
      end
    end
    File.join(dir, *extra_paths)
  end

  def scm_username
    Eh::Settings.current.repository.deploy_username
  end

  def scm_password
    Eh::Settings.current.repository.deploy_password
  end

  def scm_base_url
    Eh::Settings.current.repository.url
  end

  def repository
    "#{scm_base_url}/branches/master/releases"
  end


  def create_base_dirs(executor)
    dirs = [
      File.join(base_dir, 'config'),
      File.join(base_dir, 'ruby'),
      File.join(base_dir, 'mule'),
      File.join(base_dir, 'rails'),
      shared_dir,
      File.join(shared_dir, 'pids'),
      File.join(shared_dir, 'logs'),
      cached_copy_scp_dir
    ]
    cmds = dirs.map do |dir|
      "mkdir -p #{dir}"
    end
    executor.execute(cmds.join(" && "))
  end

  def update_scm(executor)
    dir = cached_copy_svn_dir
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

  private


  # Executes an ls on all hosts and returns the combined
  # list of files or dirs.
  def remote_ls(executor, options, pattern)
    results = executor.execute("ls #{pattern}", options)
    results.map do |result|
      if result[:stdout]
        result[:stdout].split("\n")
      end
    end.flatten.compact.uniq
  end

  def verify_deployment_list!(requested, available)
    # remove requested that are not available
    puts 'Deployment List'.light_blue.on_blue
    abort = false
    requested.each do |name|
      if available.include?(name)
        puts "#{name}: AVAILABLE".green
      else
        abort = true
        puts "#{name}: UNAVAILABLE".red
      end
    end
    if abort
      puts 'Not all requested components are available in #{cached_copy_dir}. Will abort.'.red
      raise
    end

  end

end
