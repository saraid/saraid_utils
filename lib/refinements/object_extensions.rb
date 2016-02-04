class Object
  def to_bool
    !!self
  end

  def open_url
    `open #{to_url || to_uri}` if respond_to?(:to_url) || respond_to?(:to_uri)
  end
end
