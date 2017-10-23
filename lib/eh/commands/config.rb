desc 'manage config files'
command :config do |sub_command|
  # sub command options
  sub_command.flag([:stage], desc: 'stage', type: String, long_desc: 'stage where the command is applied to', default_value: Eh::Settings.current.default_stage)
  sub_command.arg_name '[component_name,[other_component_name,pattern*]]'

  # config compare
  sub_command.desc 'compares configuration files between server local repository and actual component config'
  sub_command.command :compare do |sub_sub_command|

  end

  # config inject
  sub_command.arg_name '[component_name,[other_component_name,pattern*]]'
  sub_command.desc 'inject configuration files into actual component'
  sub_command.command :inject do |sub_sub_command|
    # sub sub command options
    sub_sub_command.switch([:r, :restart], :desc => 'restarts component when config file(s) has been changed')

  end

end
