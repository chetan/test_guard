
module TestGuard

  def self.simplecov_loaded?
    begin
      require 'simplecov'
      SimpleCov.use_merging true
      SimpleCov.merge_timeout 3600
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

    if block_given? then
      SimpleCov.start(&block)
    else
      SimpleCov.start do
        add_filter "/test/"
      end
    end
  end

end # TestGuard
