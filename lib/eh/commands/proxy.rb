desc 'enable/disable proxy'

command :proxy do |c|

  c.switch([:v, :verbose], :desc => 'Show additional output.')
  c.flag([:stage], desc: 'stage', type: String, long_desc: 'Stage where proxy is', default_value: Eh::Settings.current.default_stage)

  c.command :off do |c|

    c.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).unset
    end
  end

  c.command :on do |c|
    c.arg_name 'name'
    c.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).set(arguments[0])
    end

  end

  c.command :list do |c|
    c.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).list
    end
  end

  c.arg_name 'name'
  c.command :remove do |c|
    c.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).remove(arguments[0])
    end
  end

  c.arg_name 'name'
  c.arg_name 'proxy'
  c.command :add do |c|
    c.action do |global, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).add(arguments[0], arguments[1])
    end
  end

  c.arg_name 'name'
  c.command :select do |c|
    c.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).select(arguments[0])
    end
  end
end
