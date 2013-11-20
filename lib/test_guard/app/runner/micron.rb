
class MicronRunner < Runner

  def initialize(path, method_filter)
    super
    @cmd = %w{micron}
  end

  def run(tests)
    @cmd += @method_filter.map{ |m| "-m #{m}" } if @method_filter
    @cmd += tests if tests
    @cmd = @cmd.flatten.join(" ")
    banner("running: #{@cmd}")

    Dir.chdir(@path)
    run_micron(@cmd)
  end

  def run_all
    run([])
  end

  private

  def run_micron(cmd="micron")
    worker = Micron::Runner::ForkWorker.new(nil, false, false) {
      exec(cmd)
    }.run

    worker.wait
  end

end
