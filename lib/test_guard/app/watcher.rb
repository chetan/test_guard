
require 'growl'
require 'simplecov'
require 'simplecov-console'

require 'test_guard/app/runner'

class Watcher

  attr_accessor :run_all, :tests, :all_tests, :method, :path, :runner

  def initialize(path, options)
    @path = path

    @run_all = true
    @method = options.delete(:method)

    test_dir = File.join(@path, "test")
    test_dir = File.exists?(test_dir) ? test_dir : File.join(@path, "**", "test")

    @all_tests = Dir.glob(File.join(test_dir, "**/test_*.rb")) + Dir.glob(File.join(test_dir, "**/*_test.rb"))
    @all_tests.map!{ |t| File.expand_path(t) }.map!{ |t| t.slice(ROOT.length+1, t.length) }.sort!

    filter_tests(options.delete(:patterns))

    @runner = Runner.create(@method, @path)
  end

  def filter_tests(patterns)
    if patterns.nil? or patterns.empty? then
      @tests = @all_tests
      return
    end

    @tests = []
    patterns.each do |pat|
      # support *? glob syntax for search
      pat = pat.gsub('/', '.*/.*').gsub('*','.*').gsub('?','.')
      pat.gsub!(/\.\.\*/, '.*')
      pat = Regexp.new(pat)
      @all_tests.each do |t|
        @tests << t if pat.match(t)
      end
    end

    if @tests.empty? then
      puts "error: no matching tests found for given patterns!"
      puts
      puts "all test files:"
      puts @all_tests
      exit 1
    end

    @tests.sort!.uniq!
    @run_all = false if @tests.size < @all_tests.size
  end

  def run_test(changes=[])

    default = true
    if not changes.empty? then
      changed_tests = changes.find_all{ |c| File.basename(c) =~ /^(test_.*\.rb|.*_test.rb)$/ }
      if changed_tests.size == changes.size then
        # only tests were changed, run those specific files
        default = false
      end
    end

    if not default then
      @runner.run(changed_tests)
    elsif @run_all
      @runner.run_all
    else
      @runner.run(@tests)
    end

    if not $?.success? then
      growl("rake test failed!")
    end

    display_coverage()
  end

  def display_coverage
    if TestGuard.simplecov_loaded? then
      %w{.coverage coverage}.each { |c|
        cov_dir = File.join(ROOT, c)
        if File.directory?(cov_dir) then
          EasyCov.path = cov_dir
        end
      }
      SimpleCov.merge_timeout(86400) # make sure we load all available data
      SimpleCov::Formatter::Console.new.format(SimpleCov.result)
    end
  end

  def on_change(files)
    changes = []
    files.each do |f|
      t = false

      if f =~ %r{#{@path}/\.?coverage} then
        # TODO move excludes to var
        # skip changes in these files
        next
      end

      if f =~ %r{^test/} then
        if ROOT == @path then
          # run if any tests for *this* project change
          t = true
        end

      elsif f =~ /\.rb$/ then
        t = true
      end

      changes << f if t
    end

    return if changes.empty?

    system("clear")
    puts
    changes.each { |f| puts "changed file: #{f}" }

    run_test(changes)
  end

  private

  def growl(msg)
    Growl.notify msg, :title => "test_guard: #{PROJECT}", :sticky => false
  end

end # class Watcher
