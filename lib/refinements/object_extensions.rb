class Object
  def to_bool
    self ? true : false
  end

  def open_url
    url = to_url if respond_to? :to_url
    url ||= to_uri if respond_to? :to_uri
    `open #{url}`
  end

  def ensure(&block)
    if block.call(self)
      self
    else
      nil
    end
  end

  def if(condition, or_else:)
    #condition.call(self) ? self : or_else
    self.ensure(&condition) || or_else
  end
end
