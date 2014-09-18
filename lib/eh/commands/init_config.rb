desc 'Initializes the config directory remotely'
command :init_config do |c|
  c.flag([:s, :source], :desc => "Source config directory", :default_value => Eh::Settings.current.source_config_dir)

  c.action do |global_options, options, args|
    source_config_dir = options[:s]
    repository_deployment_dir = File.join(Eh::Settings.current.repository_root_dir, "branches", "master", "src", "deployment")

    cmd = "cd #{repository_deployment_dir} && COPY_FROM_DIR=#{source_config_dir} bundle exec cap event_hub:scp_copy_config"

    puts "Will copy config files from #{source_config_dir}"
    puts "Command: #{cmd}" if global_options['v']

    Bundler.with_clean_env do
      system cmd
    end

    puts "Done."
  end
end
