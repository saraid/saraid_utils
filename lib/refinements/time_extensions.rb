module PlusMinus
  def plusminus(interval)
    [-1, 1]
      .map { |polarity| interval * polarity }
      .map { |delta| self + delta }
      .tap { |ary| ary.singleton_class.define_method(:to_range) { first...last } }
  end
  alias ± plusminus

  module Refinements refine Time do include PlusMinus end end
end

#class Time; include PlusMinus; end
#class Date; include PlusMinus; end
