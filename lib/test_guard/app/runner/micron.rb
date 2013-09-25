
class MicronRunner < Runner

  def run(tests)
    cmd = %w{micron}
    cmd += tests
    cmd = cmd.join(" ")
    banner("running: #{cmd}")

    Dir.chdir(@path)
    system(cmd)
  end

  def run_all
    Dir.chdir(@path)
    banner("running: micron")
    system("micron")
  end

end
