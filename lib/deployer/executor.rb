require 'net/ssh'
require 'colorize'

class Deployer::Executor
  attr_reader :stage

  def initialize(stage, options = {})
    @stage = stage
    @options = options
    yield(self) if block_given?
  end

  def execute(command, options = {})
    log_command("Execute: '#{command.strip}'", options[:comment])
    stage.hosts.each_with_index.map do |host, index|
      log_host(host, index)
      result = execute_on(host, command)
      log_result(result)
      result
    end

  rescue => e
    handle_exception(e, options)
  end

  def upload(source, target, options = {})
    log_command("Execute: scp #{source} to #{target}", options[:comment])
    stage.hosts.each_with_index do |host, index|
      log_host(host, index)
      result = upload_on(host, source, target)
      log_result(result)
      result
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
      puts "    -> #{result[:stdout].chomp}".light_blue
    end
  end

  def log_host(host, index)
    print "  #{host[:host]} (#{index + 1}/#{stage.hosts.size}): "
  end

  def log_command(cmd, comment = nil)
    puts cmd.blue
    puts "  (#{comment})" if verbose? && comment
  end

  def upload_on(host, source, target)
    execute_local "scp -P #{host[:port]} #{source} #{host[:user]}@#{host[:host]}:#{target}"
  end


  def execute_on(host, command)
    Net::SSH.start(host[:host], host[:user], port: host[:port]) do |ssh|
      ssh.exec_sc!(command)
    end
  end

  def execute_local(command)
    output = nil
    exit_code = nil

    Bundler.with_clean_env do
      output = `#{command}`
      exit_code = $?
    end

    raise "Command \"#{command}\" returned exit code #{exit_code}" unless exit_code.success?

    result = {
      stdout: output,
      stderr: '',
      exit_code: 0,
    }

    result
  end

end
