module Units
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

  class Gradian < Unit.of(:angular_separation)
    def to_s; 'grad'; end
    def conversions
      { Degree => { method_names: %i( to_degrees ),
                    conversion: proc { |number| number.fdiv(100) * 90 } }
      }
    end
  end

  class Turn < Unit.of(:angular_separation)
    def to_s; ' turn'; end
    def conversions
      { Degree => { method_names: %i( to_degrees ),
                    conversion: proc { |number| number * 360 } }
      }
    end
  end

  class Quadrant < Unit.of(:angular_separation)
    def to_s; ' quadrant'; end
    def conversions
      { Degree => { method_names: %i( to_degrees ),
                    conversion: proc { |number| number * 90 } },
        Radian => { method_names: %i( to_radians ),
                    conversion: proc { |number| number * Math::PI / 2 } },
        Gradian => { method_names: %i( to_radians ),
                     conversion: proc { |number| number * 100 } }
      }
    end
  end

  class Sextant < Unit.of(:angular_separation)
    def to_s; ' sextant'; end
    def conversions
      { Degree => { method_names: %i( to_degrees ),
                    conversion: proc { |number| number * 60 } },
      }
    end
  end

  class MinuteOfArc < Unit.of(:angular_separation)
    def to_s; ' minutes of arc'; end
    def format(number)
      degrees, minutes = number.divmod(60)
      "#{degrees}°#{minutes}'"
    end
    def conversions
      { Degree => { method_names: %i( to_degrees ),
                    conversion: proc { |number| number.fdiv 60 } }
      }
    end
  end

  class SecondOfArc < Unit.of(:angular_separation)
    def to_s; ' seconds of arc'; end
    def format(number)
      minutes, seconds = number.divmod(60)
      degrees, minutes = minutes.divmod(60)
      "#{degrees}°#{minutes}'#{seconds}″"
    end
    def conversions
      { Degree => { method_names: %i( to_degrees ),
                    conversion: proc { |number| number.fdiv 3600 } }
      }
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
end
