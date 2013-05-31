
class ZeusRunner < SporkRunner

  def initialize(path, extra_flags)
    super
    @cmd = "zeus test"
    ENV["RUBYOPT"] = ""
    ENV["BUNDLE_GEMFILE"] = ""
  end

end
