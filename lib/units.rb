require_relative 'units/unit'
require_relative 'units/derived_unit'
require_relative 'units/quantity'
require_relative 'units/scalar'

require_relative 'units/monkeypatchable'
require_relative 'units/si'

require_relative 'units/of/angular_separation'
require_relative 'units/of/length'
require_relative 'units/of/mass'
require_relative 'units/of/time'

module Units
  def self.monkeypatch!
    OfAngularSeparation.monkeypatch!(into: Numeric)
    OfLength.monkeypatch!(into: Numeric)
    OfMass.monkeypatch!(into: Numeric)
    OfTime.monkeypatch!(into: Numeric)
  end
end

# Example refinement:
#
# module Foo
#   using Units::OfLength
#   def self.foo
#     1.meter
#   end
# end
#
# irb> 1.meter
# => NoMethodError (undefined method `meter' for 1:Integer)
# irb> Foo.foo
# => #<Units::Quantity:0x00007faac21ee7a8 @unit=#<Units::Meter:0x7faac283e018 :m>, @number=1>

if __FILE__ == $0
  require 'irb'
  require 'irb/completion'
  Units.monkeypatch!
  module Kernel def Scalar(x) Units::Scalar.new(x) end end
  IRB.start
end
