
class SporkRunner < Runner

  def initialize(path, extra_flags)
    super
  end

  def run(tests)
    cmd = %w{testdrb}
    cmd << @extra_flags if @extra_flags
    cmd += tests
    cmd = cmd.join(" ")
    banner("running: #{cmd}")
    system(cmd)

    # system("testdrb " + changed_tests.join(" "))
  end

  def run_all
    cmd = "testdrb test/unit"
    banner("running: #{cmd}")
    system(cmd)
  end

end
