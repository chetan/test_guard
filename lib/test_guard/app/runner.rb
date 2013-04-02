
class Runner

  def self.create(method, path, extra_flags)
    case method
    when :rake
      RakeRunner.new(path, extra_flags)
      # @test_cmd = "rake test"
    when :spork
      SporkRunner.new(path, extra_flags)
      # @test_cmd = "testdrb test/unit/"
    when :zeus
      ZeusRunner.new(path, extra_flags)
      # @test_cmd = "zeus test"
    end
  end

  def initialize(path, extra_flags)
    @path = path
    @extra_flags = extra_flags
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

require 'test_guard/app/runner/rake'
require 'test_guard/app/runner/spork'
require 'test_guard/app/runner/zeus'
