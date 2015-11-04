desc 'enable/disable proxy'

command :proxy do |c|

  c.switch([:v, :verbose], :desc => 'Show additional output.')

  c.command :off do |c|
    c.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where processor is deployed to', default_value: Eh::Settings.current.default_stage)

    c.action do |global_options, options, arguments|
      stage_path = File.join(Eh::Settings.current.stages_dir, "#{options[:stage]}.yml")
      stage = Deployer::Stage.load(options[:stage], stage_path)

      Eh::ProxySettings::Git.new(stage, options[:verbose]).unset
      Eh::ProxySettings::Svn.new(stage, options[:verbose]).unset
      Eh::ProxySettings::Shell.new(stage, options[:verbose]).unset
    end
  end

  c.command :on do |c|
    c.arg_name 'name'
    c.action do |global_options, options, arguments|
      stage_path = File.join(Eh::Settings.current.stages_dir, "#{options[:stage]}.yml")
      stage = Deployer::Stage.load(options[:stage], stage_path)
      if name = arguments[0]
        proxy = Eh::Settings.current.proxies.find { |proxy| proxy.name == name }
      else
        proxy = Eh::Settings.current.proxies.find { |proxy| proxy.current }
      end
      Eh::ProxySettings::Git.new(stage, options[:verbose]).set(proxy.url)
      Eh::ProxySettings::Svn.new(stage, options[:verbose]).set(proxy.url)
      Eh::ProxySettings::Shell.new(stage, options[:verbose]).set(proxy.url)
    end

  end

  c.command :list do |c|
    c.action do |global_options, options, arguments|
      Eh::Settings.current.proxies.each do |proxy|
        if proxy.current?
          puts "#{proxy.name} -> #{proxy.url} (current)"
        else
          puts "#{proxy.name} -> #{proxy.url}"
        end
      end
    end
  end

  c.arg_name 'name'
  c.command :remove do |c|
    c.action do |global_options, options, arguments|
      if arguments.length != 1
        raise "Need to specify the name"
      end
      name = arguments[0]

      if Eh::Settings.current.proxies.find { |proxy| proxy.name == name }.nil?
        raise "No proxy with name #{name}"
      end

      Eh::Settings.current.data['proxies'].reject! { |json| json['name'] == name}
      Eh::Settings.current.write

    end
  end

  c.arg_name 'name'
  c.arg_name 'proxy'
  c.command :add do |c|
    c.action do |global, options, args|
      if args.length != 2
        raise "Need to specify the name and the proxy as arguments"
      end
      name = args[0]
      url = args[1]
      # check if same repo already exists
      exists = Eh::Settings.current.proxies.any? do |proxy|
        name == proxy.name || url == proxy.url
      end
      if exists
        raise "Already configured proxy for '#{name} -> #{url}'"
      end

      Eh::Settings.current.data['proxies'] << {
        'url' => url,
        'name' => name,
        'current' => (Eh::Settings.current.proxies.length == 0)
      }
      Eh::Settings.current.write
    end
  end

  c.arg_name 'name'
  c.command :select do |c|
    c.action do |global_options, options, arguments|
      if arguments.length != 1
        raise "Need to specify the name"
      end
      name = arguments[0]

      if Eh::Settings.current.proxies.find { |proxy| proxy.name == name }.nil?
        raise "No proxy with name #{name}"
      end
      Eh::Settings.current.data['proxies'].each do |json|
        json['current'] = (json['name'] == name)
      end
      Eh::Settings.current.write
    end
  end
end
