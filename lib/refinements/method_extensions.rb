class Method
  def native?
    source_location.nil?
  end
end
