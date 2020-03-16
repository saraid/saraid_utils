module Units
  class Scalar < Quantity
    def initialize(number)
      super(number, nil)
    end

    def to_s
      number.to_s
    end

    def +(other)
      case other
      when Quantity then other.class.new(other.number + number, other.unit)
      else super
      end
    end

    def *(other)
      case other
      when Quantity then other.class.new(number * other.number, other.unit)
      else super
      end
    end

    def /(other)
      case other
      when Quantity then other.class.new(number / other.number, DerivedUnit.for(:/, 1, other.unit))
      else super
      end
    end
  end
end
