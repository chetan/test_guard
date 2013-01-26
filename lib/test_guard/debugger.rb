
# patch debugger so we can save & restore $stdout/$stderr properly
# which is needed because our Turn formatter supresses these by default
#
# to use, create a file called .rdebugrc in project home with contents:
# eval TestGuard.save

begin
  require 'debugger'

  module TestGuard
    def self.save
      @stdout = $stdout
      @stderr = $stderr
      $stdout = STDOUT
      $stderr = STDERR
    end
    def self.restore
      return if @stdout.nil?
      $stdout = @stdout
      $stderr = @stderr
    end
  end

  module Debugger
    class CommandProcessor < Processor # :nodoc:
      private
      def postloop(commands, context)
        TestGuard.restore
      end
    end
  end

rescue LoadError => ex
end
