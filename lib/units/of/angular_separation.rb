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
