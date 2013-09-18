
require "coverage"
require "simplecov"

require "fileutils"
require "multi_json"
require "lockfile"

require "easycov/filters"

module EasyCov

  include EasyCov::Filters

  class << self
    attr_accessor :root, :path, :resolve_symlinks

    # Start coverage engine
    # Can be run multiple times without side-effect.
    def start
      @resolve_symlinks = true if @resolve_symlinks.nil?
      @path ||= File.expand_path("coverage")
      @root ||= Dir.pwd # only set first time
      Coverage.start
    end

    # Dump coverage to disk in a thread-safe way
    def dump
      Coverage.start # always make sure we are started

      FileUtils.mkdir_p(@path)
      output = File.join(@path, ".resultset.json")

      # lock in case we are in a threaded/multiproc env
      Lockfile.new(File.join(@path, ".lockfile")) do
        # load existing if avail
        data = File.exists?(output) ? MultiJson.load(File.read(output)) : {}

        # merge our data
        result = apply_filters(Coverage.result)

        time = Time.new
        name = "Test #{time.strftime('%Y%m%d.%H%M%S')} #{Random.rand(1_000_000)}"
        data[name] = {
          :coverage  => result,
          :timestamp => time.to_i
        }

        # write
        File.open(output, 'w'){ |f| f.write(MultiJson.dump(data)) }
      end # lock

    end # dump

    # Write coverage to disk and restart
    def checkpoint
      dump()
      start()
    end

    # List of filters
    def filters
      @filters ||= []
    end

    # Add filter block
    def filter(&block)
      filters << block
    end

    # Set path to coverage dir
    def path=(path)
      @path = File.expand_path(path)
    end

    def install_exit_hook
      Kernel.at_exit do
        EasyCov.checkpoint
        # if Process.pid == EasyCov::TOP_PID then
        #   # last process exiting, run default formatter (html)
        #   SimpleCov::ResultMerger.merged_result.format!
        # end
      end
    end



    private

    # Apply filters
    def apply_filters(result)

      ret = {}

      if @resolve_symlinks then
        # resolve any symlinks in paths
        result.each do |file,cov|
          next if not File.exists? file
          f = File.realpath(file)
          if f != file then
            ret[f] = cov
          else
            ret[file] = cov
          end
        end

      else
        ret = result.dup
      end

      # apply filters
      filters.each do |filter|
        ret.delete_if { |file, cov|
          filter.call(file)
        }
      end

      return ret
    end

  end # self

  TOP_PID = Process.pid
end

# Patch to use our path
module SimpleCov
  class << self
    def coverage_path
      EasyCov.path
    end
  end
end
