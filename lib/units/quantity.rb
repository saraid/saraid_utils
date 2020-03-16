module Units
  class Quantity
    def initialize(number, unit)
      @number, @unit = number, unit
      if unit
        unit.conversions.each do |to_unit, details|
          singleton_class.class_eval do
            details[:method_names].each do |method_name|
              define_method(method_name) { convert(to_unit) }
            end
          end
        end
      end
    end
    attr_reader :number, :unit

    def to_s
      unit.format(number)
    end

    def <=>(other)
      raise ArgumentError, "cannot compare #{self} with #{other.inspect}" unless other.unit == unit
      number <=> other.number
    end

    def -@
      self * -1
    end

    def +(other)
      case other
      when Numeric then self + Scalar.new(other)
      when Scalar then self.class.new(number + other.number, unit)
      when Quantity
        if unit != other.unit && !other.unit.can_convert_to?(unit)
          raise ArgumentError, 'cannot add different quantities with units' 
        end
        self.class.new(number + other.number, unit)
      end
    end

    def -(other)
      self + -other
    end

    def **(other)
      case other
      when Numeric then self ** Scalar.new(other)
      when Scalar then self.class.new(number ** other.number, unit)
      when Quantity then raise ArgumentError, 'cannot raise by a non-dimensionless quantity; what are you even doing'
      end
    end

    def *(other)
      case other
      when Numeric then self / Scalar.new(other)
      when Scalar then self.class.new(number * other.number, unit)
      when Quantity then self.class.new(number * other.number, DerivedUnit.for(:*, unit, other.unit))
      end
    end

    def /(other)
      case other
      when Numeric then self / Scalar.new(other)
      when Scalar then self.class.new(number / other.number, unit)
      when Quantity then self.class.new(number / other.number, DerivedUnit.for(:/, unit, other.unit))
      end
    end

    def convert(to_unit)
      to_unit = to_unit.instance if to_unit.is_a?(Class) && to_unit.respond_to?(:instance)
      unit
        .convert(to_unit)
        .call(number)
        .yield_self { |converted| self.class.new(converted, to_unit) }
    end

    def respond_to_missing?(id, include_private = false)
      super || number.respond_to?(id, include_private)
    end

    def method_missing(id, *args, &block)
      return number.public_send(id, *args, &block) if number.respond_to?(id) && id.to_s.match?(/^to_/)
      return self.class.new(number.public_send(id, *args, &block), unit) if number.respond_to?(id)
      super
    end
  end
end
