
class ZeusRunner < SporkRunner

  def initialize(path)
    super
    @cmd = "zeus test"
    ENV["RUBYOPT"] = ""
    ENV["BUNDLE_GEMFILE"] = ""
  end

end
