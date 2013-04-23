
require 'optparse'
require 'guard'

require 'test_guard/app/watcher'


options = {
  :dirs     => [ ROOT ],
  :patterns => [],
  :method   => :rake
}
method_filter = []

parser = OptionParser.new do |opts|
  opts.banner = "usage: #{File.basename($0)} [options]"

  opts.on("-l", "--list", "List all test files") do
    options[:list] = true
  end

  opts.on("-t", "--test PATTERN", "Only run test(s) matching pattern") do |p|
    options[:patterns] << p
  end

  opts.on("-m", "--method PATTERN", "Only run test methods matching pattern") do |p|
    p.strip!
    method_filter << p if not p.empty?
  end

  opts.on("-d", "--directory DIR", "Additional directory to watch") do |dir|
    dir = File.expand_path(dir)
    if not File.directory? dir then
      STDERR.puts "directory #{dir} not found!"
      exit 1
    end
    options[:dirs] << dir
  end

  opts.on("-R", "--rake", "Use rake for running tests (default)") do
    options[:method] = :rake
  end

  opts.on("-S", "--spork", "Use spork for running tests") do
    options[:method] = :spork
  end

  opts.on("-Z", "--zeus", "Use zeus for running tests") do
    options[:method] = :zeus
  end

  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on("-v", "--version", "Display version") do
    puts "test_guard v" + File.read(File.join(File.dirname(__FILE__), "..", "..", "VERSION"))
    exit
  end

end

begin
  parser.parse!
rescue Exception => ex
  exit if ex.kind_of? SystemExit
  STDERR.puts "error: #{ex}"
  STDERR.puts
  STDERR.puts parser
  exit 1
end

# find matching tests
watcher = Watcher.new(ROOT, options)

if options[:list] then
  puts "all test files:"
  puts
  puts watcher.all_tests
  exit
end

# start listener for each dir
listener = Listen::MultiListener.new(*options[:dirs]) do |mod, add, del|
  files = mod + add + del
  watcher.on_change(files)
end
listener.start(false)

system("clear")

puts
puts "* watching directories: "
puts listener.directories
puts

if not watcher.run_all then
  puts "* only running the following tests:"
  puts watcher.tests
  puts
end

# delete existing coverage data
cov_dir = File.join(ROOT, "coverage")
if File.directory? cov_dir then
  puts "* deleting existing coverage data"
  puts
  system("rm -rf #{cov_dir}")
end

if not method_filter.empty? then
  ENV["TURN_PATTERN"] = method_filter.join("|")
end

# run all tests at start
watcher.run_test()

trap "INT" do
  puts
  puts "bye!"
  exit
end

while true
  sleep 1 # spin forever
end