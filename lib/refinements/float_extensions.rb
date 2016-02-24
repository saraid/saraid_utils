class Float
  def truncate(places = 2)
    multiplier = 10 ** places.to_i
    (self * multiplier).to_i.to_f / multiplier
  end
end
