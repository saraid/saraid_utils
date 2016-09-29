class << ARGV
  def get(regex, default = nil)
    self.grep(regex).first || default
  end

  # Based off: http://faculty.knox.edu/dbunde/teaching/chapel/#Declaration%20Modifiers
  def consume(*args)
    variable_name = args[0]
    type = args[1]
    default = args[2]

    value = grep(/--#{variable_name}=(.*)/).first
    unless value.nil?
      value = value.sub(/.*=/, '')
    end

    begin
      if Kernel.respond_to?(type.name.to_sym)
        Kernel.send(type.name.to_sym, value)
      elsif type.respond_to?(:from_s)
        type.from_s(value)
      elsif type.respond_to?(:try_convert)
        type.try_convert(value)
      end
    rescue
      default
    end || default
  end
end
