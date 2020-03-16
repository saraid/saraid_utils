module Units
  class Meter < Unit.of(:length)
    def to_s; 'm'; end
  end

  SI.expand_prefixes(Meter)

  class Foot < Unit.of(:length)
    def to_s; 'ft'; end
    def conversions
      { Yard => { method_names: %i( to_yards ),
                  conversion: proc { |number| number.fdiv 3 } },
        Mile => { method_names: %i( to_miles ),
                  conversion: proc { |number| number.fdiv 5280 } }
      }
    end
  end

  class Yard < Unit.of(:length)
    def to_s; ' yard'; end
  end

  class Mile < Unit.of(:length)
    def to_s; ' mile'; end
  end

  module OfLength
    extend Monkeypatchable

    def meters
      Units::Quantity.new(self, Units::Meter.instance)
    end
    alias meter meters

    def kilometers
      Units::Quantity.new(self, Units::Kilometer.instance)
    end
    alias kilometer kilometers
    alias km kilometers

    refine Numeric do
      include OfLength
    end
  end
end
