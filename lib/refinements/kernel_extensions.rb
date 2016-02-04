module Kernel
  def pbcopy(string)
    string.to_s.copy
  end

  def pbpaste
    `pbpaste`.chop
  end
  alias :paste :pbpaste

  def open_url(url)
    `open #{url.to_s}`
  end
end
