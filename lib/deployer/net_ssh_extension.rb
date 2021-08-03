class Net::SSH::Connection::Session
  def exec_sc!(command, verbose = false)
    stdout_data, stderr_data = "", ""
    exit_code, exit_signal = nil, nil
    open_channel do |channel|
      channel.exec(command) do |_, success|
        raise "Command \"#{command}\" was unable to execute" unless success

        channel.on_data do |_, data|
          if verbose
            puts
            puts data.light_blue.on_white if verbose
          end
          stdout_data += data
        end

        channel.on_extended_data do |_, _, data|
          if verbose
            puts
            puts data.light_blue.on_white if verbose
          end
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
    raise stderr_data unless exit_code == 0

    {
      stdout: stdout_data,
      stderr: stderr_data,
      exit_code: exit_code,
      exit_signal: exit_signal
    }
  end
end
