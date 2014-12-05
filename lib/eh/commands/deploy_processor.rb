desc 'deploy a single processor'
arg_name 'processor_name stage'

command :deploy_processor do |c|
  c.action do |global_options, options, args|
    #require 'active_support/core_ext/string/inflections'
    #require 'fileutils'
    #require 'erb'
    require 'net/scp'
    if args.size < 1
      puts "Needs at least one argument: processor_name"
      exit -1
    end

    processor_name = args[0]
    stage = args[1] || 'development'

    p "deploying #{processor_name} to #{stage}"

    base = "/apps/compoundbank/s_cme/apps/event_hub"
    source = "#{Eh::Settings.current.releases_dir}/ruby/#{processor_name}.zip"
    target_copy = "#{base}/eh-releases/ruby"
    target_unzip = "#{base}/eh-current/ruby"

    Net::SSH.start('localhost', 's_cme', {:port => 2222}) do |ssh|
      # copy
      p "copy"
      ssh.scp.upload! source, target_copy

      # unpack
      p "unpack"
      p ssh.exec!("unzip -o -d #{target_unzip} #{target_copy}/#{processor_name}.zip; echo $?")

      # copy config


      # restart

    end


  end
end
