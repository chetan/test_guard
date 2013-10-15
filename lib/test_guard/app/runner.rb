
require "micron"
require "micron/runner/fork_worker"

class Runner

  def self.create(method, path, method_filter)
    case method
    when :micron
      MicronRunner.new(path, method_filter)
    when :rake
      RakeRunner.new(path, method_filter)
    when :spork
      SporkRunner.new(path, method_filter)
    when :zeus
      ZeusRunner.new(path, method_filter)
    end
  end

  def initialize(path, method_filter)
    @path = path
    @method_filter = method_filter
  end

  # Run specific list of tests
  #
  # @param [String] tests       filenames of tests to run
  def run(tests)
    raise NotImplementedError, "run method must be overriden!"
  end

  # Run all the tests in the project
  def run_all
    raise NotImplementedError, "run_all method must be overriden!"
  end


  private

  def banner(msg)
    puts "-"
    puts msg
    puts "-" * 80
    puts
  end

end

require 'test_guard/app/runner/micron'
require 'test_guard/app/runner/rake'
require 'test_guard/app/runner/spork'
require 'test_guard/app/runner/zeus'
