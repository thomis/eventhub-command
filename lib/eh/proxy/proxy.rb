module Eh
  module Proxy
    require 'uri'
    require_relative 'settings/git'
    require_relative 'settings/svn'
    require_relative 'settings/shell'

    class Proxy
      def initialize(stage_name, verbose)
        @stage_name = stage_name
        @verbose = verbose
      end

      def set(name = nil)
        proxy = find_proxy_by_name(name) || find_default_proxy
        if proxy.nil?
          raise "No proxy found"
        end
        Eh::Proxy::Settings::Git.new(stage, verbose).set(proxy.url)
        Eh::Proxy::Settings::Svn.new(stage, verbose).set(proxy.url)
        Eh::Proxy::Settings::Shell.new(stage, verbose).set(proxy.url)
      end

      def unset
        Eh::Proxy::Settings::Git.new(stage, verbose).unset
        Eh::Proxy::Settings::Svn.new(stage, verbose).unset
        Eh::Proxy::Settings::Shell.new(stage, verbose).unset
      end

      def remove(name)
        raise "Needs a proxy NAME to remove" if name.nil?
        proxy = find_proxy_by_name(name)
        if proxy.nil?
          raise "No proxy with given name [#{name}]"
        end

        Eh::Settings.current.data['proxies'].reject! { |json| json['name'] == name}
        Eh::Settings.current.write
        puts "Proxy [#{name}] has been removed".green
      end

      def add(name, url)
        if name.nil? || url.nil?
          raise "Please provide NAME and PROXY_URL"
        end
        if find_proxy_by_name(name) || find_proxy_by_url(url)
          raise "Already configured proxy for [#{name} -> #{url}]"
        end

        Eh::Settings.current.data['proxies'] << {
          'url' => url,
          'name' => name,
          'default' => (Eh::Settings.current.proxies.length == 0)
        }
        Eh::Settings.current.write
        puts "Proxy [#{name}] has been added".green
      end

      def select(name)
        raise "Needs a proxy NAME to select" if name.nil?
        proxy = find_proxy_by_name(name)
        if proxy.nil?
          raise "No proxy found with given name [#{name}]"
        end

        Eh::Settings.current.data['proxies'].each do |json|
          json['default'] = (json['name'] == name)
        end
        Eh::Settings.current.write
        puts "Proxy [#{name}] has been selected".green
      end

      def list
        puts "Defined Proxies"
        Eh::Settings.current.proxies.each do |proxy|
          puts proxy.label.send( proxy.label =~ /\(default\)/ ? :green : :white )
        end
      end

      private
      attr_reader :stage_name, :verbose

      def stage
        @stage ||= Deployer::Stage.load(stage_name, stage_path)
      end

      def stage_path
        File.join(Eh::Settings.current.stages_dir, "#{stage_name}.yml")
      end

      def find_proxy_by_name(name)
        Eh::Settings.current.proxies.find { |proxy| proxy.name == name }
      end

      def find_proxy_by_url(url)
        Eh::Settings.current.proxies.find { |proxy| proxy.url == url }
      end

      def find_default_proxy
        Eh::Settings.current.proxies.find { |proxy| proxy.default }
      end

    end
  end
end
