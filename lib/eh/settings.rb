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

  def releases_dir
    File.join(repository_root_dir, 'releases')
  end

  def rails_release_dir
    File.join(releases_dir, 'rails')
  end

  def ruby_release_dir
    File.join(releases_dir, 'ruby')
  end

  def processes_src_dir
    File.join(repository_root_dir, 'src', 'process')
  end

  def deployment_dir
    File.join(repository_root_dir, 'src', 'deployment')
  end

  def rails_src_dir
    File.join(repository_root_dir, 'src', 'rails', 'console')
  end

  def source_config_dir
    File.join(repository_root_dir, 'config')
  end

  def processor_template_repository_url
    "git@github.com:thomis/eventhub-processor-template.git"
  end

  def package_tmp_dir
    './tmp'
  end

end