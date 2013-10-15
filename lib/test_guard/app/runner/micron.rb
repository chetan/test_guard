
class MicronRunner < Runner

  def run(tests)
    cmd = %w{micron}
    cmd += @method_filter.map{ |m| "-m #{m}" }
    cmd += tests
    cmd = cmd.join(" ")
    banner("running: #{cmd}")

    Dir.chdir(@path)
    run_micron(cmd)
  end

  def run_all
    Dir.chdir(@path)
    banner("running: micron")
    run_micron()
  end

  private

  def run_micron(cmd="micron")
    worker = Micron::Runner::ForkWorker.new(nil, false, false) {
      exec(cmd)
    }.run

    worker.wait
  end

end
