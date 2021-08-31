require "net/ssh"
require "colorize"

class Deployer::Executor
  attr_reader :stage, :commands

  def initialize(stage, options = {})
    @stage = stage
    @options = options

    reset_commands

    yield(self) if block_given?
  end

  # execute a command on all hosts of a stage
  # commands are expanded with :hostname, :port and :stagename
  def execute(command, options = {})
    log_command("Execute: '#{command.strip}'", options[:comment])
    stage.hosts.each_with_index.map do |host, index|
      expand_options = {hostname: host[:host], stagename: stage.name, port: host[:port]}

      expanded_command = command % expand_options
      if expanded_command != command
        log_command("Expanded command to #{expanded_command}")
      end
      log_host(host, index)
      result = execute_on(host, expanded_command)
      log_result(result)
      result
    end
  rescue => e
    handle_exception(e, options)
  end

  def execute_later(command, options = {})
    log_command("Execute later: '#{command.strip}'", options[:comment])
    stage.hosts.each_with_index.map do |host, index|
      expand_options = {hostname: host[:host], stagename: stage.name, port: host[:port]}
      expanded_command = command % expand_options
      if expanded_command != command
        log_command("Expanded command to #{expanded_command}")
      end
      @commands[host] << expanded_command
    end
  end

  def execute_batch
    results = []
    @commands.each_with_index do |(host, cmds), index|
      log_host(host, index)
      result = execute_on(host, cmds.join("\n"))
      log_result(result)
      results << result
    end
    results.join("\n")
  rescue => e
    handle_exception(e, {})
  end

  def execute_on(host, command)
    Net::SSH.start(host[:host], host[:user], port: host[:port]) do |ssh|
      ssh.exec_sc!(command, verbose?)
    end
  end

  def download(source, target, options = {})
    log_command("Execute: download via scp #{source} from #{target}", options[:comment])
    stage.hosts.each_with_index do |host, index|
      log_host(host, index)
      result = download_from(host, source, target)
      log_result(result)
      result
    end
  rescue => e
    handle_exception(e, options)
  end

  def upload(source, target, options = {})
    log_command("Execute: upload via scp #{source} to #{target}", options[:comment])
    stage.hosts.each_with_index do |host, index|
      log_host(host, index)
      result = upload_on(host, source, target)
      log_result(result)
      result
    end
  rescue => e
    handle_exception(e, options)
  end

  def reset_commands
    @commands = Hash.new { |h, k| h[k] = [] }
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
    puts filter(cmd).blue
    puts "  (#{comment})" if verbose? && comment
  end

  def upload_on(host, source, target)
    execute_local "scp -P #{host[:port]} #{source} #{host[:user]}@#{host[:host]}:#{target}"
  end

  def download_from(host, source, target)
    execute_local "scp -P #{host[:port]} #{host[:user]}@#{host[:host]}:#{source} #{target}"
  end

  def filter(text)
    text.gsub(/--password (\S)+/, "--password [FILTERED]")
  end

  def execute_local(command)
    output = nil
    exit_code = nil

    Bundler.with_clean_env do
      output = `#{command}`
      exit_code = $?
    end

    raise "Command \"#{command}\" returned exit code #{exit_code}" unless exit_code.success?

    {
      stdout: output,
      stderr: "",
      exit_code: 0
    }
  end
end
