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
      result = execute_on(hostname, command)
      if result[:exit_code].success?
        puts "'#{command}' on '#{hostname}' successfully executed: #{result[:status]}"
      else
        raise "Could not execute command '#{command}' on '#{host}': #{result[:status]}"
      end
    end
  end

  def upload(source, target)
    hostnames.each do |hostname|
      result = upload_on(hostname, source, target)

      if result[:exit_code].success?
        puts "#{hostname}: scp: from #{source} to #{target} successful"
      else
        raise "Could not execute command '#{command}' on '#{host}': #{result[:status]}"
      end
    end
  end


  private

  def upload_on(hostname, source, target)
    execute_locally "scp -P #{port} #{source} #{username}@#{hostname}:#{target}"
  end

  def execute_on(hostname, command)
    result = nil

    result = Net::SSH.start(hostname, username, port: port) do |ssh|
      ssh.capture3(command)
    end

    result = {
      stdout: result[0],
      stderr: result[1],
      exit_code: result[2],
    }

    result
  end

  def execute_ugly_on(hostname, command)
    # -n don't read from stdin
    # -t -t enable pseudo-tty
    command = "ssh #{username}@#{hostname} -n -p #{port} -t -t \"#{command}\""

    result = execute_locally command
    unless result[:exit_code].success?
      raise "Could not execute command '#{command}' on '#{host}': #{status}"
    end

    result
  end

  def execute_locally(command)
    output = nil
    exit_code = nil

    Bundler.with_clean_env do
      output = `#{command}`
      exit_code = $?
    end

    result = {
      stdout: output,
      stderr: '',
      exit_code: exit_code,
    }

    result
  end

end
