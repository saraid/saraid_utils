module Units
  class DerivedUnit < Unit
    class Factor
      def self.flatten(factors)
        factors
          .map(&:flatten)
          .flatten
          .group_by(&:unit)
          .transform_values { |ary| ary.map(&:exponent).reduce(0, :+) }
          .map { |unit, exponent| Factor.new(unit, exponent) }
      end

      def initialize(unit, exponent)
        @unit, @exponent = unit, exponent
      end
      attr_reader :unit, :exponent

      def flatten
        if unit.kind_of?(DerivedUnit) then unit.factors.map { |f| Factor.new(f.unit, f.exponent * exponent) }
        else [self]
        end
      end
    end

    def self.for(operator, left_operand, right_operand)
      case operator
      when :** then [Factor.new(left_operand, right_operand)]
      when :*  then [Factor.new(left_operand, 1), Factor.new(right_operand, 1)]
      when :/  then [Factor.new(left_operand, 1), Factor.new(right_operand, -1)]
      end
        .yield_self(&Factor.method(:flatten))
        .tap { |factors| return factors.first.unit if factors.size == 1 && factors.first.exponent == 1 }
        .yield_self(&method(:new))
    end

    def initialize(factors)
      @factors = factors
    end
    attr_reader :factors

    def to_s
      @factors.map do |factor|
        case factor.exponent
        when 1 then factor.unit
        else "#{factor.unit}^#{factor.exponent}"
        end
      end.join('·')
    end

    def format(number)
      "#{number} #{to_s}"
    end
  end
end
