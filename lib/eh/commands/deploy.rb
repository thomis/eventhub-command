desc 'Deploys the app'
arg_name 'stage', optional: true

command :deploy do |c|
  c.flag([:deploy_via], :desc => "One of 'copy' or 'scm'", :default_value => 'scm')
  c.flag([:copy_from_dir], :desc => "Source directory for copy operation", :default_value => Eh::Settings.current.releases_dir)
  c.flag([:tag], :desc => "The tag to deploy")
  c.flag([:branch], :desc => "The branch to deploy", :default_value => "master")

  c.action do |global_options, options, args|
    stage = args[0] || "development"

    deployment_dir = Eh::Settings.current.deployment_dir

    env_variables = []
    env_variables << "DEPLOY_VIA=#{options[:deploy_via]}"

    if options[:tag]
      env_variables << "TAG=#{options[:tag]}"
    else
      env_variables << "BRANCH=#{options[:branch]}"
    end

    if options[:deploy_via] == "copy"
      env_variables << "COPY_FROM_DIR=#{options[:copy_from_dir]}"
    end

    cmd = "cd #{deployment_dir} && #{env_variables.join(' ')} bundle exec cap #{stage} event_hub"

    puts "Command: #{cmd}" if global_options['v']

    Bundler.with_clean_env do
      system cmd
    end

    puts "Done."
  end
end
