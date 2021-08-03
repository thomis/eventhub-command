module Eh::Proxy::Settings
  class Shell
    def initialize(stage, verbose = true)
      @stage = stage
      @verbose = verbose
    end

    def set(value)
      Deployer::Executor.new(stage, verbose: verbose?) do |executor|
        executor.execute(set_command(value), abort_on_error: false)
      end
    end

    def unset
      Deployer::Executor.new(stage, verbose: verbose?) do |executor|
        executor.execute(unset_command, abort_on_error: false)
      end
    end

    private

    def proxy_file
      "~/.proxy"
    end

    def verbose?
      @verbose
    end

    attr_reader :stage

    def unset_command
      "rm -f #{proxy_file} ; touch #{proxy_file}"
    end

    def set_command(value)
      "echo '#{set_content(value)}' > #{proxy_file}"
    end

    def set_content(value)
      "export http_proxy=#{value}\nexport https_proxy=#{value}"
    end
  end
end
