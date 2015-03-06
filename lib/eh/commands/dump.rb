desc "manage repositories"

command :dump do |command|
  command.desc "Create a backup"
  command.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where processor is deployed to', default_value: Eh::Settings.current.default_stage)
  command.switch([:v, :verbose], :desc => 'Show additional output.')

  command.command :download do |command|

    command.action do |global_options, options, args|
      source = File.join('/tmp', "dump-#{args[0]}.zip")
      target = File.join('/tmp', "dump-#{args[0]}.zip")
      dir = File.join('/tmp', "dump-#{args[0]}")

      cmds = []
      host = stage(options).single_host_stage.hosts[0]

      system "scp -P #{host[:port]} #{host[:user]}@#{host[:host]}:#{source} #{target}"
      system "unzip -d #{dir} #{target}"
      puts "Downloaded dump to #{target} and extracted to #{dir.green}"
    end
  end

  command.command :create do |command|

    command.action do |global_options, options, args|
      stamp = Time.now.strftime("%Y%m%d-%H%M%S")
      dir = File.join('/tmp', "dump-#{stamp}")
      zip_target = File.join('/tmp', "dump-#{stamp}.zip")
      logstash_source = '~/apps/event_hub/shared/logs/logstash_output.log'
      cmds = []
      cmds << "mkdir -p #{dir}"
      cmds << "cd #{dir} && pg_dump -Uevent_hub_console event_hub_console > console_pg.sql"
      cmds << "if [[ -f #{logstash_source} ]] ; then cp #{logstash_source} #{File.join(dir, 'logstash_output.log')} ; fi"
      cmds << "cd #{dir} && zip -r #{zip_target} ."
      cmds << "rm -rf #{dir}"


      Deployer::Executor.new(stage(options).single_host_stage, verbose: options[:verbose]) do |executor|
        cmds.each do |cmd|
          executor.execute(cmd)
        end
      end


      puts "Created an dump in #{zip_target}. Use #{stamp.green} as identifier for eh dump download."
    end
  end


  private

  def stage(options)
    @stage ||= begin
      stage_path = File.join(Eh::Settings.current.stages_dir, "#{options[:stage]}.yml")
      Deployer::Stage.load(options[:stage], stage_path)
    end
  end
end
