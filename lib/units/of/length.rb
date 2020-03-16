module Units
  class Meter < Unit.of(:length)
    def to_s; 'm'; end
  end

  SI.expand_prefixes(Meter)

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
