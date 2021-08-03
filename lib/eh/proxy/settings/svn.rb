require "tempfile"
require "parseconfig"
module Eh::Proxy::Settings
  class Svn
    def initialize(stage, verbose = true)
      @stage = stage
      @verbose = verbose
    end

    def unset
      Deployer::Executor.new(stage, verbose: verbose?) do |executor|
        executor.download("~/.subversion/servers", temporary_config_file)
        config = ParseConfig.new(temporary_config_file)

        config["global"].delete("http-proxy-host")
        config["global"].delete("http-proxy-port")
        config["global"].delete("http-proxy-username")
        config["global"].delete("http-proxy-password")
        File.open(temporary_config_file, "w") do |file|
          config.write(file, false)
        end
        executor.upload(temporary_config_file, "~/.subversion/servers")
      end
    end

    def set(value)
      uri = URI.parse("http://#{trim_url(value)}")

      Deployer::Executor.new(stage, verbose: verbose?) do |executor|
        executor.download("~/.subversion/servers", temporary_config_file)
        config = ParseConfig.new(temporary_config_file)
        config["global"]["http-proxy-host"] = uri.host
        config["global"]["http-proxy-port"] = uri.port
        File.open(temporary_config_file, "w") do |file|
          config.write(file, false)
        end
        executor.upload(temporary_config_file, "~/.subversion/servers")
      end
    end

    private

    def verbose?
      @verbose
    end

    attr_reader :stage

    def unset_command
    end

    def temporary_config_file
      @temporary_config_file ||= Dir::Tmpname.make_tmpname([Dir.tmpdir, "subversion_servers"], nil)
    end
  end
end
