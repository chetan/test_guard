
class RakeRunner < Runner

  def initialize(path, method_filter)
    super

    @loader = File.join(Gem.loaded_specs["rake"].full_gem_path, "lib", "rake", "rake_test_loader.rb")
  end

  def run(tests)
    cmd = %w{ruby}
    cmd << "-Itest" if File.exist? File.join(@path, "test")
    cmd << "-I.test" if File.exist? File.join(@path, ".test")
    cmd << @loader
    cmd += tests
    cmd = cmd.join(" ")
    banner("running: #{cmd}")

    Dir.chdir(@path)
    system(cmd)
  end

  def run_all
    Dir.chdir(@path)
    banner("running: rake test")
    system("rake test")
  end

end
