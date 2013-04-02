
class SporkRunner < Runner

  def initialize(path, extra_flags)
    super
    @cmd = "testdrb"
  end

  def run(tests)
    cmd = [@cmd]
    cmd += tests
    cmd = cmd.join(" ")
    banner("running: #{cmd}")
    system(cmd)
  end

  def run_all
    cmd = "#{@cmd} test/unit"
    banner("running: #{cmd}")
    system(cmd)
  end

end
