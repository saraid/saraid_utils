module Units
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

  class Hour < Unit.of(:time)
    def to_s; ' hours'; end
    def conversions
      { Second => { method_names: %i( in_seconds ),
                    conversion: proc { |n| n * 3600 } }
      }
    end
  end

  class Day < Unit.of(:time)
    def to_s; ' days'; end
    def conversions
      { Second => { method_names: %i( in_seconds ),
                    conversion: proc { |n| n * 3600 * 24 } }
      }
    end
  end

  class MeanTropicalYear < Unit.of(:time)
    def to_s; ' mean tropical years'; end
    def conversions
      { Second => { method_names: %i( in_seconds ),
                    conversion: proc { |n| n * 365.24219 * 86400 } }
      }
    end
  end

  class MeanGregorianYear < Unit.of(:time)
    def to_s; ' mean Gregorian years'; end
    def conversions
      { Second => { method_names: %i( in_seconds ),
                    conversion: proc { |n| n * 365.2425 * 86400 } }
      }
    end
  end

  class MeanJulianYear < Unit.of(:time)
    def to_s; ' mean Julian years'; end
    def conversions
      { Second => { method_names: %i( in_seconds ),
                    conversion: proc { |n| n * 365.25 * 86400 } }
      }
    end
  end

  class Annus < Unit.of(:time)
    def to_s; 'a'; end
  end
  Annum = Annus

  class Megaannum < Unit.of(:time)
    def to_s; ' Ma'; end
    def conversions
      { Annum => { method_names: %i( in_annums ),
                   conversion: proc { |n| n * 1_000_000 } }
      }
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
end
