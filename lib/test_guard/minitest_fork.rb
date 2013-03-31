
require "parallel"

class ParallelEach

  ##
  # Starts N child procs that yield each element to your block. Joins the
  # threads at the end.

  def map
    tests = []
    while not @queue.empty? do
      tests << @queue.pop
    end
    tests.reject! { |t| t.nil? }

    Parallel.map(tests, :in_processes => ENV["N"].to_i) do |test|
      yield test
    end
  end
end
