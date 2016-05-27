require 'fileutils'
require 'pathname'
require 'pliny/version'
require 'pliny/commands/creator'
require 'uri'

module Pliny::Commands
  class Updater < Creator
    attr_accessor :stream

    def self.run(stream = $stdout)
      new(stream).run!
    end

    def initialize(stream = $stdout)
      @stream = stream
    end

    def run!
      unless File.exist?("Gemfile.lock")
        abort("Pliny app not found - looking for Gemfile.lock")
      end

      version_current = get_current_version
      version_target  = Gem::Version.new(Pliny::VERSION)

      if version_current == version_target
        display "Version #{version_current} is current, nothing to update."
      elsif version_current > version_target
        display "pliny-update is outdated. Please update it with `gem install pliny` or similar."
      else
        display "Updating from #{version_current} to #{version_target}..."

        display template_dir
        display app_dir
        FileUtils.copy_entry template_dir, app_dir
        parse_erb_files
      end
    end

    def get_current_version
      File.read("./Gemfile.lock").split("\n").each do |line|
        next unless pliny_version = line.match(/pliny \(([\d+\.]+)\)/)
        return Gem::Version.new(pliny_version[1])
      end
    end

    def name
      Config.app_name
    end

    def app_dir
      Dir.pwd
    end
  end
end
