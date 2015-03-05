class Eh::Settings

  attr_reader :data, :file

  class Repository
    def initialize(json)
      @json = json
    end

    def url
      @json['url']
    end

    def deploy_username
      @json['deploy_username']
    end

    def deploy_password
      @json['deploy_password']
    end

    def dir
      @json['dir']
    end

    def current?
      @json['current']
    end
  end

  def initialize(file)
    @file = file
    @data = JSON.parse(File.read(file))
  end

  def self.load(file)
    Eh::Settings.new(file)
  end

  def write
    File.open(file,"w") do |f|
      f.write(data.to_json)
    end
  end

  def self.current=(value)
    Thread.current[:eh_settings] = value
  end

  def self.current
    Thread.current[:eh_settings]
  end

  def repository
    repositories.find do |repository|
      repository.current?
    end if repositories
  end

  def repositories
    repos = data["repositories"].map do |json|
      Eh::Settings::Repository.new(json)
    end if data["repositories"]
    repos || []
  end

  def releases_dir(*extra_paths)
    File.join(repository.dir, 'releases', *extra_paths)
  end


  def rails_release_dir
    releases_dir('rails')
  end

  def ruby_release_dir
    releases_dir('ruby')
  end

  def processors_src_dir
    File.join(repository.dir, 'src', 'ruby')
  end

  def rails_src_dir
    File.join(repository.dir, 'src', 'rails')
  end

  def console_source_dir
    File.join(repository.dir, 'src', 'rails', 'console')
  end

  def deployment_dir
    File.join(repository.dir, 'src', 'deployment')
  end

  def rails_src_dir
    File.join(repository.dir, 'src', 'rails', 'console')
  end

  def source_config_dir
    File.join(repository.dir, 'config')
  end

  def processor_template_repository_url
    'https://github.com/thomis/eventhub-processor-template.git'
  end

  def package_tmp_dir
    './tmp'
  end

  def template_tmp_dir
    '/tmp/eventhub-processor-template/'
  end

  def deployment_management_files
    [ File.join(deployment_dir, 'management', 'launcher.rb') ]
  end

  def stages_dir
    File.join(repository.dir, 'config', 'stages')
  end
end
