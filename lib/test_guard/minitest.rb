
require 'minitest/unit'

class MiniTest::Unit::TestCase

  # minitest assert_throws doesn't seem to work properly
  def assert_throws(clazz, msg = nil, &block)
    begin
      yield
    rescue Exception => ex
      if clazz.to_s == ex.class.name then
        if msg.nil?
          return
        elsif msg == ex.message then
          return
        end
      end
      puts "unexpected exception caught:"
      puts "#{ex.class}: #{ex.message}"
      puts ex.backtrace.join("\n")
      puts
    end
    flunk("Expected #{mu_pp(clazz)} to have been thrown")
  end

end

# Set the # of parallel tests to the # of cpus (or 4 if we can't detect)
if not ENV.include? "N" or ENV["N"].empty? then
  def num_processors(default=4)
    if RUBY_PLATFORM =~ /linux/ then
      out = `cat /proc/cpuinfo | grep 'model name' | wc -l`
      return $1.to_i if $?.success? && out =~ /(\d+)/
    elsif RUBY_PLATFORM =~ /darwin/ then
      out = `hostinfo | grep physical | egrep -o '^[0-9]+'`
      return out.strip.to_i if $?.success?
    end
    return default
  end
  ENV["N"] = num_processors.to_s
end
