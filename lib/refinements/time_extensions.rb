class Time
  def plusminus(interval)
    [-1, 1]
      .map { |polarity| interval * polarity }
      .map { |delta| self + delta }
      .tap { |ary| ary.singleton_class.define_method(:to_range) { first...last } }
  end
end
