
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
