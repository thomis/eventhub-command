desc "Manage proxies"
command :proxy do |proxy|
  proxy.switch([:v, :verbose], desc: "Show additional output.")
  proxy.flag([:stage], desc: "stage", type: String, long_desc: "Stage where proxy is", default_value: Eh::Settings.current.default_stage)

  proxy.desc "List defined proxies"
  proxy.command :list do |list|
    list.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).list
    end
  end

  proxy.desc "Select proxy by NAME"
  proxy.arg_name "NAME"
  proxy.command :select do |select|
    select.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).select(arguments[0])
    end
  end

  proxy.desc "Enable proxy default or by NAME"
  proxy.arg_name "NAME"
  proxy.command :on do |on|
    on.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).set(arguments[0])
    end
  end

  proxy.desc "Disable default proxy"
  proxy.command :off do |off|
    off.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).unset
    end
  end

  proxy.desc "Add new proxy by NAME and PROXY_URL"
  proxy.arg_name "NAME PROXY_URL"
  proxy.command :add do |add|
    add.action do |global, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).add(arguments[0], arguments[1])
    end
  end

  proxy.desc "Remove by NAME"
  proxy.arg_name "NAME"
  proxy.command :remove do |remove|
    remove.action do |global_options, options, arguments|
      Eh::Proxy::Proxy.new(options[:stage], options[:verbose]).remove(arguments[0])
    end
  end

  proxy.default_command :list
end
