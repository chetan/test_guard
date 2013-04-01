
require 'growl'
require 'simplecov'
require 'simplecov-console'

class Watcher

  attr_accessor :run_all, :tests, :all_tests, :method, :path

  def initialize(path, options)
    @path = path

    @run_all = true
    @method = options.delete(:method)

    case @method
    when :rake
      @test_cmd = "rake test"
    when :spork
      @test_cmd = "testdrb test/unit/"
    when :zeus
      @test_cmd = "zeus test"
    end

    @all_tests = Dir.glob(File.join(@path, "./**/test_*.rb")) + Dir.glob(File.join(@path, "./**/*_test.rb"))
    @all_tests.map!{ |t| File.expand_path(t) }.map!{ |t| t.slice(ROOT.length+1, t.length) }.sort!

    filter_tests(options.delete(:patterns))

    # read extra flags from .test_guard or .testguard
    [ File.join(ROOT, ".test_guard"), File.join(ROOT, ".testguard") ].each do |config|
      if File.exist? config then
        @extra_flags = File.read(config).strip
        break
      end
    end

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

  def run_bundle
    banner("running: bundle update")
    system("bundle update")
    if not $?.success? then
      growl("bundle update failed!")
    end
    run_test()
  end

  def run_test(changes=[])
    if @method == :spork and not changes.empty? then
      changed_tests = changes.find_all{ |c| c =~ %r{^#{ROOT}/test/} }
      if changed_tests.size == changes.size then
        # only tests were changed, run those specific files
        system("testdrb " + changed_tests.join(" "))

      else
        system(@test_cmd)
      end

    else

      if @run_all then
        system(@test_cmd)
      else

        if rake? then
          cmd = %w{ruby}
          cmd << @extra_flags if @extra_flags
          cmd << @tests.first
          cmd = cmd.join(" ")
          banner("running: #{cmd}")
          system(cmd)
        end

      end

    end

    if not $?.success? then
      growl("rake test failed!")
    end

    SimpleCov::Formatter::Console.new.format(SimpleCov.result)
  end

  def on_change(files)
    b = t = false
    changes = []
    files.each do |f|

      #f =~ %r{test\/(factories|test_.*?)\.rb$} or f =~ /^test_guard\.rb$/ or
      if f =~ %r{#{ROOT}/coverage} then
        # TODO move excludes to var
        # skip changes in these files
        next
      end

      if f == "Gemfile" then # ignore .lock
        b = true
      elsif f =~ %r{^test/} then
        if ROOT == @path then
          # run if any tests for *this* project change
          t = true
        end
      elsif f =~ /\.rb$/ then
        t = true
      end

      if b or t then
        changes << f
      end

    end

    if not changes.empty? then
      system("clear")
      puts
      changes.each { |f| puts "changed file: #{f}" }
    end

    sleep 1 # wait for changes to flush to disk??

    if b then
      run_bundle()
    elsif t then
      run_test(changes)
    end
  end

  def rake?
    @method == :rake
  end

  def spork?
    @method == :spork
  end

  def zeus?
    @method == :zeus
  end

  private

  def banner(msg)
    puts "-"
    puts msg
    puts "-" * 80
    puts
  end

  def growl(msg)
    Growl.notify msg, :title => "test_guard: #{PROJECT}", :sticky => true
  end

end # class Watcher
