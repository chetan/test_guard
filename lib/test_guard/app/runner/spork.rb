
class SporkRunner < MicronRunner

  def initialize(path, method_filter)
    super
    @cmd = %w{testdrb}
  end

end
