require 'net/ssh'
require 'net-ssh-open3'
class Executor
  attr_reader :hostnames, :username, :port
  def initialize(username, port, *hostnames)
    @hostnames = hostnames
    @username = username
    @port = port
    yield(self) if block_given?
  end

  def execute(command)
    hostnames.each do |hostname|
      stdin, stderr, status = execute_on(hostname, command)
      if status.exitstatus != 0
        raise "Could not execute command '#{command}' on '#{host}': #{status}"
      else
        puts "'#{command}'' on '#{hostname}'' successfuly executed: #{status}"
      end
    end
  end

  def upload(source, target)

  end



  private


  def execute_on(hostname, command)
    Net::SSH.start(hostname, username, port: port) do |ssh|
      ssh.capture3(command)
    end
  end
end


Executor.new('s_cme', 2222, 'localhost', 'localhost') do |executor|
  executor.execute('echo $?')
end
