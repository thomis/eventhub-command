class Eh::Settings
  attr_reader :data
  def self.load(file)
    data = File.read(file)
    json = JSON.parse(data)
    Eh::Settings.new(json)
  end

  def self.current=(value)
    Thread.current[:eh_settings] = value
  end

  def self.current
    Thread.current[:eh_settings]
  end

  def initialize(data)
    @data = data
  end


  def repository_root_dir
    File.expand_path(data['repository_root_dir'])
  end

  def release_dir
    File.join(repository_root_dir, 'releases', 'ruby')
  end

  def processes_src_dir
    File.join(repository_root_dir, 'src', 'process')
  end

  def package_tmp_dir
    './tmp'
  end

end