
module Rake
  class << self
    def verbose?
      ENV.include? "VERBOSE" and ["1", "true", "yes"].include? ENV["VERBOSE"]
    end
  end
end
