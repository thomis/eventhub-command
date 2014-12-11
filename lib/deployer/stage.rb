class Deployer::Stage
  attr_reader :name, :node_env, :hosts

  def initialize(name, node_env)
    @name = name
    @node_env = node_env
    @hosts = []
  end

  def host(host, port, user)
    @hosts << {
      host: host,
      port: port,
      user: user
    }
  end

  def self.load(file)
    data = YAML.load_file(file)
    data.map do |name, config|
      stage = Deployer::Stage.new(name, config['node_env'])
      config['hosts'].each do |host|
        stage.host(host['host'], host['port'], host['user'])
      end
      stage
    end.first
  end
end
