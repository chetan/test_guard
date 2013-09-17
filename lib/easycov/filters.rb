
module EasyCov
  module Filters

    # Ignore files in <root>/test/
    IGNORE_TESTS = lambda { |filename|
      filename =~ %r{^#{EasyCov.root}/test/}
    }

    # Ignore all filfes outside EasyCov.root (pwd by default)
    IGNORE_OUTSIDE_ROOT = lambda { |filename|
      filename !~ /^#{EasyCov.root}/
    }

    # Ignore all ruby STDLIB files
    STDLIB_PATHS = `ruby -e 'puts $:'`.strip.split(/\n/)
    IGNORE_STDLIB = lambda { |filename|
      STDLIB_PATHS.each do |path|
        if filename =~ /^#{path}/ then
          return true
        end
      end
      false
    }

    # Ignore all gems (uses GEM_PATH if set, else /gems/ in filename)
    IGNORE_GEMS = lambda { |filename|
      if ENV["GEM_PATH"] && !ENV["GEM_PATH"].empty? then
        # use GEM_PATH if avail
        ENV["GEM_PATH"].split(':').each do |path|
          if filename =~ /^#{path}/ then
            return true
          end
        end

        false

      else
        # simple regex
        filename =~ %r{/gems/}
      end
    }

  end
end
