module Kernel
  def pbcopy(string)
    string.to_s.copy
  end

  def pbpaste
    `pbpaste`.chop
  end
  alias :paste :pbpaste
end
