class Deployer::ConsoleDeployer < Deployer::BaseDeployer

  def initialize(options)
    @options = options
  end

  def deploy!
    Bundler.with_clean_env do
      Dir.chdir(console_dir) do
        system "bundle install && cap #{stage} deploy"
      end
    end
  end

  private

  def console_dir
    Eh::Settings.current.console_source_dir
  end

  def stage
    @options.fetch(:stage, 'development')
  end
end
