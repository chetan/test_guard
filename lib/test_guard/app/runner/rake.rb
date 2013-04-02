
class RakeRunner < Runner

  def initialize(path, extra_flags)
    super

    @loader = File.join(Gem.loaded_specs["rake"].full_gem_path, "lib", "rake", "rake_test_loader.rb")
  end

  def run(tests)
    cmd = %w{ruby}
    cmd << @extra_flags if @extra_flags
    cmd << @loader
    cmd += tests
    cmd = cmd.join(" ")
    banner("running: #{cmd}")

    Dir.chdir(@path)
    system(cmd)
  end

  def run_all
    Dir.chdir(@path)
    system("rake test")
  end

end
