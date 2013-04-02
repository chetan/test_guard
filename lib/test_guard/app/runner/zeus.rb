
class ZeusRunner < SporkRunner

  def initialize(path, extra_flags)
    super
    @cmd = "zeus test"
  end

end
