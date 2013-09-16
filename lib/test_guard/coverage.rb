
module TestGuard

  def self.load_simplecov(&block)
    begin
      require 'simplecov'
      SimpleCov.command_name "test:#{Time.new.strftime('%Y%m%d.%H%M%S')}"
      SimpleCov.start do
        add_filter "/test/"
        yield if block_given?
      end
    rescue Exception => ex
    end
  end

end # TestGuard
