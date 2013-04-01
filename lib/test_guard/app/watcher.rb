
require 'growl'
require 'simplecov'
require 'simplecov-console'

class Watcher

  def initialize(path, options)
    @path = path

    @method = options.delete(:method)

    case @method
    when :rake
      @test_cmd = "rake test"
    when :spork
      @test_cmd = "testdrb test/unit/"
    when :zeus
      @test_cmd = "zeus test"
    end

  end

  def run_bundle
    puts "-"
    puts "running: bundle update"
    puts "-" * 80
    puts
    system("bundle update")
    if not $?.success? then
      growl("bundle update failed!")
    end
    run_test()
  end

  def run_test(changes=[])
    puts "-"
    puts "running: rake test"
    puts "-" * 80
    puts

    if @method == :spork and not changes.empty? then
      tests = changes.find_all{ |c| c =~ %r{^#{ROOT}/test/} }
      if tests.size == changes.size then
        # only tests were changed, run those specific files
        system("testdrb " + tests.join(" "))

      else
        system(@test_cmd)
      end

    else
      system(@test_cmd)
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



  private

  def growl(msg)
    Growl.notify msg, :title => "test_guard: #{PROJECT}", :sticky => true
  end

end # class Watcher
