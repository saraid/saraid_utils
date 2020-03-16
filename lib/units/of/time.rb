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
