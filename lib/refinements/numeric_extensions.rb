class Numeric
  def bound_with(range)
    case 
    when range.begin > self then range.begin
    when range.end < self then range.end
    else self
    end
  end
end
