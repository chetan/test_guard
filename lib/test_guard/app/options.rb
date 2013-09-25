
require 'optparse'

module TestGuard
  class Options

    DEFAULTS = {
      :dirs          => [],
      :patterns      => [],
      :method_filter => [],
      :method        => :rake,
      :poll          => false
    }

    def self.parse

      options = DEFAULTS.dup

      parser = OptionParser.new do |opts|
        opts.banner = "usage: #{File.basename($0)} [options]"

        opts.on("-l", "--list", "List all test files") do
          options[:list] = true
        end

        opts.on("-t", "--test PATTERN", "Only run test(s) matching pattern") do |p|
          options[:patterns] << p
        end

        opts.on("-m", "--method PATTERN", "Only run test methods matching pattern") do |p|
          p.strip!
          options[:method_filter] << p if not p.empty?
        end

        opts.on("-d", "--directory DIR", "Additional directory to watch") do |dir|
          dir = File.expand_path(dir)
          if not File.directory? dir then
            STDERR.puts "directory #{dir} not found!"
            exit 1
          end
          options[:dirs] << dir
        end

        opts.on("--root DIR", "Set root directory for running tests") do |dir|
          options[:root] = File.expand_path(dir)
        end

        opts.on("--pwd", "Use pwd as root directory for running tests") do
          options[:root] = File.expand_path(Dir.pwd)
        end

        opts.on("--poll", "Force polling while watching directories (useful for VMs or NFS)") do
          options[:poll] = true
        end

        # Different test runner implementations
        opts.on("-M", "--micron", "Use micron for running tests") do
          options[:method] = :micron
        end

        opts.on("-R", "--rake", "Use rake for running tests (default)") do
          options[:method] = :rake
        end

        opts.on("-S", "--spork", "Use spork for running tests") do
          options[:method] = :spork
        end

        opts.on("-Z", "--zeus", "Use zeus for running tests") do
          options[:method] = :zeus
        end

        opts.on("--clean", "Delete existing coverage data before running") do
          options[:clean] = true
        end

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on("-v", "--version", "Display version") do
          puts "test_guard v" + File.read(File.join(File.dirname(__FILE__), "..", "..", "VERSION"))
          exit
        end

      end

      begin
        parser.parse!
      rescue Exception => ex
        exit if ex.kind_of? SystemExit
        STDERR.puts "error: #{ex}"
        STDERR.puts
        STDERR.puts parser
        exit 1
      end

      return options

    end

  end
end
