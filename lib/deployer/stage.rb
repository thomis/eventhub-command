class Deployer::Stage
  attr_reader :name, :hosts

  def initialize(name)
    @name = name
    @hosts = []
  end

  def host(host, port, user)
    @hosts << {
      host: host,
      port: port,
      user: user
    }
    self
  end

  # returns a new stage which only contains one host
  #
  def single_host_stage
    stage = Deployer::Stage.new(name)
    stage.host(hosts[0][:host], hosts[0][:port], hosts[0][:user])
    stage
  end

  def self.load(name, file)
    data = YAML.load_file(file)
    data.map do |_, config|
      stage = Deployer::Stage.new(name)
      config['hosts'].each do |host|
        stage.host(host['host'], host['port'], host['user'])
      end
      stage
    end.first
  end
end
