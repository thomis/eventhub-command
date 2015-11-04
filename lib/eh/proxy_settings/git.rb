module Eh::ProxySettings
  class Git
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

    def verbose?
      @verbose
    end

    attr_reader :stage

    def unset_command
      "git config --global --unset http.proxy ; git config --global --unset https.proxy"
    end

    def set_command(value)
      "git config --global http.proxy http://#{value} ; git config --global https.proxy https://#{value}"
    end
  end
end
