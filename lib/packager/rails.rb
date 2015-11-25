class Packager::Rails
  def initialize(source_dir, destination_dir)
    @source_dir = source_dir
    @destination_dir = destination_dir
  end

  def package

    app_directories.each do |dir|
      included = files_and_dirs.map do |s|
        File.join(app_name(dir), s)
      end.join(' ')
      remove_destination_file(dir)
      cmd = "cd #{File.join(dir, '..')} && zip -r #{destination_file_name(dir)} #{included} >> /dev/null"
      ret = system cmd
      puts "Packaged: #{app_name(dir).blue} to #{destination_file_name(dir)}: #{ret ? 'OK'.green : 'ERROR'.red}"
    end
  end

  private

  attr_reader :source_dir, :destination_dir

  def app_directories
    Dir.glob(source_dir)
  end

  def app_name(dir)
    File.basename(dir)
  end

  def destination_file_name(dir)
    app_name = app_name(dir)
    File.join(destination_dir, "#{app_name}.zip")
  end

  def files_and_dirs
    %w{Capfile Gemfile Gemfile.lock README.rdoc Rakefile app bin db lib public spec vendor}
  end

  def remove_destination_file(dir)
    FileUtils.rm destination_file_name(dir), force: true
  end
end


# files_and_dirs =
# source = options[:source]
#
# dirs = Dir.glob("#{source}")
# dirs.each do |dir|
#   app = File.basename(dir)
#   destination = File.join(options[:d], "#{app}.zip")
#   included = files_and_dirs.map do |s|
#     File.join(app, s)
#   end.join(' ')
#   cmd = "cd #{File.join(dir, '..')} && zip -r #{destination} #{included}"
#   ret = system cmd
#   puts "Packaged #{app}: #{ret}"
# end
