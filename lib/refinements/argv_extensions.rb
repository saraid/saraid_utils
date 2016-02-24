class << ARGV
  def get(regex, default = nil)
    self.grep(regex).first || default
  end
end
