module Units
  class Gram < Unit.of(:mass)
    def to_s; 'g'; end
  end

  SI.expand_prefixes(Gram)

  module OfMass
    extend Monkeypatchable

    def grams
      Units::Quantity.new(self, Units::Gram.instance)
    end
    alias gram grams

    def kilograms
      Units::Quantity.new(self, Units::Kilogram.instance)
    end
    alias kilogram kilograms
    alias kg kilograms

    refine Numeric do
      include OfMass
    end
  end
end
