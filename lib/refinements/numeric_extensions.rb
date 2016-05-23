class Numeric
  def bound_with(range)
    case 
    when range.begin > self then range.begin
    when range.end < self then range.end
    else self
    end
  end

  def days
    24 * self.hours
  end
  alias :day :days

  def hours
    60 * self.minutes
  end
  alias :hour :hours

  def minutes
    60 * self.seconds
  end
  alias :minute :minutes

  def seconds
    self
  end
  alias :second :seconds

  # Expecting a Time or Date or DateTime parameter
  def since(time)
    case time
    when Date, Time, DateTime then time + self
    else raise ArgumentError.new('#since takes a Time-like')
    end
  end

  def as_percent_of(total)
    percent = self.to_f / total * 100
    percent = 0 if percent.nan?
    percent.to_f
  end
end
