require 'net/ssh'
require 'colorize'


class Net::SSH::Connection::Session
  class CommandFailed < StandardError
  end

  class CommandExecutionFailed < StandardError
  end

  def exec_sc!(command)
    stdout_data,stderr_data = "",""
    exit_code,exit_signal = nil,nil
    self.open_channel do |channel|
      channel.exec(command) do |_, success|
        raise CommandExecutionFailed, "Command \"#{command}\" was unable to execute" unless success

        channel.on_data do |_, data|
          stdout_data += data
        end

        channel.on_extended_data do |_, _, data|
          stderr_data += data
        end

        channel.on_request("exit-status") do |_, data|
          exit_code = data.read_long
        end

        channel.on_request("exit-signal") do |_, data|
          exit_signal = data.read_long
        end
      end
    end
    self.loop
    raise CommandFailed, stderr_data unless exit_code == 0

    {
      stdout: stdout_data,
      stderr: stderr_data,
      exit_code: exit_code,
      exit_signal: exit_signal
    }
  end
end

class Executor
  attr_reader :hostnames, :username, :port

  def initialize(username, port, hostnames, options = {})
    @hostnames = hostnames
    @username = username
    @port = port
    @options = options
    yield(self) if block_given?
  end


  def execute(command, options = {})
    log_command("Execute: '#{command}'", options[:comment])
    hostnames.each_with_index do |hostname, index|
      log_hostname(hostname, index)
      result = execute_on(hostname, command)
      log_result(result)
    end

  rescue => e
    handle_exception(e, options)
  end

  def upload(source, target, options = {})
    log_command("Execute: scp #{source} to #{target}", options[:comment])
    hostnames.each_with_index do |hostname, index|
      log_hostname(hostname, index)
      result = upload_on(hostname, source, target)
      log_result(result)
    end

  rescue => e
    handle_exception(e, options)
  end


  private
  def handle_exception(e, options)
    if options[:abort_on_error] == false
      puts "warning".black.on_yellow
      puts "    #{e.message}".yellow
    else
      puts "failure".black.on_red
      puts "    #{e.message}".red
    end
    raise unless options[:abort_on_error] == false

  end

  def verbose?
    @options[:verbose]
  end

  def log_result(result)
    puts "success".black.on_green
    if verbose? && result[:stdout] && result[:stdout].length > 0
      puts "    -> #{result[:stdout].chomp}".blue
    end
  end

  def log_hostname(hostname, index)
    print "  #{hostname} (#{index + 1}/#{hostnames.size}): "
  end

  def log_command(cmd, comment = nil)
    puts cmd.light_blue
    puts "  (#{comment})" if verbose? && comment
  end

  def upload_on(hostname, source, target)
    execute_locally "scp -P #{port} #{source} #{username}@#{hostname}:#{target}"
  end

  def execute_on(hostname, command)
    Net::SSH.start(hostname, username, port: port) do |ssh|
      ssh.exec_sc!(command)
    end
  end

  def execute_locally(command)
    output = nil
    exit_code = nil

    Bundler.with_clean_env do
      output = `#{command}`
      exit_code = $?
    end

    raise CommandFailed, "Command \"#{command}\" returned exit code #{exit_code}" unless exit_code.success?

    result = {
      stdout: output,
      stderr: '',
      exit_code: 0,
    }

    result
  end

end
