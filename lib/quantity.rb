module Units
  class Unit
    def self.instance
      @instance ||= new
    end

    def self.of(type)
      (@types ||= {})[type] ||= Class.new(self) do
        @type = type

        def self.name
          "Unit_of#{@type.to_s.capitalize}"
        end

        def type
          self.class.superclass
        end
      end.tap do |cls|
        Units.const_set(cls.name.to_sym, cls)
      end
    end

    def format(number)
      [number, to_s].join
    end

    def can_convert_to?(unit)
      conversions.key?(unit) || conversions.key?(unit.class)
    end

    def convert(unit)
      raise ArgumentError, 'cannot convert between different types' unless unit.type == type
      conversions[unit.class][:conversion]
    end
  end

  class DerivedUnit < Unit
    def self.for(operator, *operands)
      @registry ||= {}
      @registry[operator] ||= {}
      @registry[operator][operands] ||= new(operator, operands)
    end

    def initialize(operator, operands)
      @operator = operator
      @operands = operands
    end

    def format(number)
      case @operator
      when :* then @operands.map(&:to_s).join('·').prepend("#{number} ")
      when :/ then @operands.map(&:to_s).join('/').prepend("#{number} ")
      else raise "Whoops"
      end
    end
  end

  class Meter < Unit.of(:length)
    def to_s; 'm'; end
  end

  class Second < Unit.of(:time)
    def to_s; 's'; end
    def conversions
      { Minute => { method_names: %i( in_minutes ),
                    conversion: proc { |n| n.fdiv(60).rationalize } }
      }
    end
  end

  class Minute < Unit.of(:time)
    def to_s; ' minutes'; end
    def conversions
      { Second => { method_names: %i( in_seconds ),
                    conversion: proc { |n| n * 60 } }
      }
    end
  end

  class Gram < Unit.of(:mass)
    def to_s; 'g'; end
  end

  class Degree < Unit.of(:angular_separation)
    def to_s; '°'; end
    def conversions
      { Radian => { method_names: %i( to_radians ),
                    conversion: proc { |number| number * Math::PI / 180 } }
      }
    end
  end

  class Radian < Unit.of(:angular_separation)
    def to_s; 'rad'; end
    def conversions
      { Degree => { method_names: %i( to_degrees ),
                    conversion: proc { |number| number * 180 / Math::PI } }
      }
    end
  end

 #ANGULAR_UNITS = [
 #  Turn, Quadrant,
 #  Sextant, Radian,
 #  Hexacontade, BinaryDegree,
 #  Degree, Grad,
 #  MinuteOfArc, SecondOfArc
 #]

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

  class Scalar < Quantity
    def initialize(number)
      super(number, nil)
    end

    def to_s
      number.to_s
    end
  end

  module Monkeypatchable
    def monkeypatch!(into:)
      into.include(self)
    end
  end

  module OfLength
    extend Monkeypatchable

    def meters
      Units::Quantity.new(self, Units::Meter.instance)
    end
    alias meter meters

    refine Numeric do
      include OfLength
    end
  end

  module OfTime
    extend Monkeypatchable

    def seconds
      Units::Quantity.new(self, Units::Second.instance)
    end
    alias second seconds

    refine Numeric do
      include OfLength
    end
  end

  module OfAngularSeparation
    extend Monkeypatchable

    def degrees
      Units::Quantity.new(self, Units::Degree.instance)
    end
    alias degree degrees

    def radians
      Units::Quantity.new(self, Units::Radian.instance)
    end
    alias radian radians

    refine Numeric do
      include OfAngularSeparation
    end
  end

  def self.monkeypatch!
    OfLength.monkeypatch!(into: Numeric)
    OfTime.monkeypatch!(into: Numeric)
    OfAngularSeparation.monkeypatch!(into: Numeric)
  end
end

if __FILE__ == $0
  require 'irb'
  require 'irb/completion'
  Units.monkeypatch!
  module Kernel def Scalar(x) Units::Scalar.new(x) end end
  IRB.start
end
