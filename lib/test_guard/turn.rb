
require 'turn'
require 'turn/reporter'
require 'turn/reporters/outline_reporter'

Turn.config.framework = :minitest
Turn.config.format = :outline
Turn.config.natural = true

module Turn
  class OutlineReporter < Reporter
    def start_test(test)

      @last_test = test

      # create new captures for each test (so we don't get repeated messages)
      @stdout = StringIO.new
      @stderr = StringIO.new

      name = naturalized_name(test)

      io.print "    %-57s" % name

      @stdout.rewind
      @stderr.rewind

      $stdout = @stdout
      $stderr = @stderr unless $DEBUG

      @clean = false
      at_exit do
        if not @clean then
          puts "program quit unexpectedly!"
          show_captured_output()
        end
      end
    end

    def finish_test(test)
      super
      @clean = true
    end

    # override so we can dump stdout/stderr even if the test passes
    def pass(message=nil)
      io.puts " %s %s" % [ticktock, PASS]

      if message
        message = Colorize.magenta(message)
        message = message.to_s.tabto(TAB_SIZE)
        io.puts(message)
      end

      @clean = true
      show_captured_output if Rake.verbose?
    end

    # override to add test name to output
    def show_captured_stdout
      @clean = true
      @stdout.rewind
      return if @stdout.eof?
      STDOUT.puts(<<-output.tabto(8))
\n\nSTDOUT (#{naturalized_name(@last_test)}):
-------------------------------------------------------------------------------

#{@stdout.read}
      output
    end
  end
end

if $0 == __FILE__ then
  # require all test cases if not running via rake
  $: << File.expand_path(File.dirname(__FILE__))
  Dir.glob(File.expand_path(File.dirname(__FILE__)) + "/**/*.rb").each do |f|
    next if f =~ /test\/performance/ or f == File.expand_path(__FILE__)
    require f
  end
end
