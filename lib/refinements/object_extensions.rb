class Object
  def to_bool
    !!self
  end

  def open_url
    url = to_url if respond_to? :to_url
    url ||= to_uri if respond_to? :to_uri
    `open #{url}`
  end
end
