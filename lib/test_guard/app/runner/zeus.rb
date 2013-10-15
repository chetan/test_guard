
class ZeusRunner < SporkRunner

  def initialize(path, method_filter)
    super
    @cmd = "zeus test"
    ENV["RUBYOPT"] = ""
    ENV["BUNDLE_GEMFILE"] = ""
  end

end
