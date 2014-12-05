require_relative 'executor'

desc 'deploy a single processor'
arg_name 'processor_name stage'

command :deploy_processor do |c|
  c.action do |global_options, options, args|
    if args.size < 1
      puts "Needs at least one argument: processor_name"
      exit -1
    end

    processor_name = args[0]
    stage = args[1] || 'development'

    puts "deploying #{processor_name} to #{stage}"

    base = "/apps/compoundbank/s_cme/apps/event_hub"
    source = "#{Eh::Settings.current.releases_dir}/ruby/#{processor_name}.zip"
    target_copy = "#{base}/eh-releases/ruby/"
    target_unzip = "#{base}/eh-current/ruby/"

    Executor.new('s_cme', 2222, 'localhost') do |executor|
      puts "copy"
      file_name = File.basename source
      destination = File.join(target_copy, file_name)
      executor.upload(source, destination)

      puts "unpack"
      executor.execute("unzip -o -d #{target_unzip} #{target_copy}/#{processor_name}.zip; echo $?")
    end

  end
end
