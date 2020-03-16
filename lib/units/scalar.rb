module Units
  class Scalar < Quantity
    def initialize(number)
      super(number, nil)
    end

    def to_s
      number.to_s
    end
  end
end
