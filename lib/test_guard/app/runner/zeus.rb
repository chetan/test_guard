
class ZeusRunner < MicronRunner

  def initialize(path, method_filter)
    super
    @cmd = %w{zeus test}
    ENV["RUBYOPT"] = ""
    ENV["BUNDLE_GEMFILE"] = ""
  end

end
