
require 'test_guard/app/options'
require 'test_guard/coverage'

require 'listen'

options = TestGuard::Options.parse

# Set working dir
if options[:root] then
  ROOT = options[:root]
else
  ROOT = File.expand_path(File.dirname(Bundler.setup(:default, :development).default_gemfile))
end
PROJECT = File.basename(ROOT)
options[:dirs].unshift(ROOT)
Dir.chdir(ROOT)

# find matching tests
require 'test_guard/app/watcher'
watcher = Watcher.new(ROOT, options)

if options[:list] then
  puts "all test files:"
  puts
  puts watcher.all_tests
  exit
end

# start listener for each dir
listener = Listen::Listener.new(*options[:dirs], :force_polling => options[:poll]) do |mod, add, del|
  files = mod + add + del
  watcher.on_change(files)
end
listener.start

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
if options[:clean] && File.directory?(cov_dir) then
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
