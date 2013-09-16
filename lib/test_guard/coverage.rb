
module TestGuard

  def self.simplecov_loaded?
    begin
      require 'simplecov'
      return true
    rescue Exception => ex
    end
    return false
  end

  def self.load_simplecov(&block)
    if not simplecov_loaded? then
      puts "simplecov not available; disabling coverage"
      return
    end
    SimpleCov.command_name "test:#{Time.new.strftime('%Y%m%d.%H%M%S')}"
    SimpleCov.merge_timeout 3600
    SimpleCov.start do
      add_filter "/test/"
      yield if block_given?
    end
  end

end # TestGuard
