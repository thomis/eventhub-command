class Eh::Settings
  attr_reader :data, :file

  class Repository
    def initialize(json)
      @json = json
    end

    def url
      @json["url"]
    end

    def deploy_username
      @json["deploy_username"]
    end

    def deploy_password
      @json["deploy_password"]
    end

    def dir
      @json["dir"]
    end

    def current?
      @json["current"]
    end
  end

  class Proxy
    def initialize(json)
      @name = json["name"]
      @default = json["default"]
      @url = json["url"]
    end
    attr_reader :name, :url, :default

    def default?
      !!@default
    end

    def label
      label = "#{name} -> #{url}"
      label << " (default)" if default?
      label
    end
  end

  def default_stage
    @data["default_stage"] || "development"
  end

  def initialize(file)
    @file = file
    @data = JSON.parse(File.read(file))
    @data["proxies"] ||= []
  end

  def self.load(file)
    Eh::Settings.new(file)
  end

  def write
    File.write(file, data.to_json)
  end

  def self.current=(value)
    Thread.current[:eh_settings] = value
  end

  def self.current
    Thread.current[:eh_settings]
  end

  def repository
    repositories&.find do |repository|
      repository.current?
    end
  end

  def repositories
    if data["repositories"]
      repos = data["repositories"].map do |json|
        Eh::Settings::Repository.new(json)
      end
    end
    repos || []
  end

  def proxies
    if data["proxies"]
      proxies = data["proxies"].map do |json|
        Eh::Settings::Proxy.new(json)
      end
    end
    proxies || []
  end

  def releases_dir(*extra_paths)
    File.join(repository.dir, "releases", *extra_paths)
  end

  def rails_release_dir
    releases_dir("rails")
  end

  def ruby_release_dir
    releases_dir("ruby")
  end

  def go_release_dir
    releases_dir("go")
  end

  def ruby_processors_src_dir
    File.join(repository.dir, "src", "ruby")
  end

  def go_processors_src_dir
    File.join(repository.dir, "src", "go", "src", "github.com", "cme-eventhub")
  end

  def console_source_dir
    File.join(repository.dir, "src", "rails", "console")
  end

  def deployment_dir
    File.join(repository.dir, "src", "deployment")
  end

  def rails_src_dir
    # appears 2 times. What is correct?
    File.join(repository.dir, "src", "rails", "console")
  end

  def source_config_dir
    File.join(repository.dir, "config")
  end

  def processor_template_repository_url
    "https://github.com/thomis/eventhub-processor-template.git"
  end

  def package_tmp_dir
    "./tmp"
  end

  def template_tmp_dir
    "/tmp/eventhub-processor-template/"
  end

  def deployment_management_files
    [File.join(deployment_dir, "management", "launcher.rb")]
  end

  def stages_dir
    File.join(repository.dir, "config", "stages")
  end

  def db_backups_dir
    File.expand_path("~/backups")
  end
end
