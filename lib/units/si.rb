module Units
  module SI
    PREFIXES = {
      yotta: [ 'Y', 24 ],
      zetta: [ 'Z', 21 ],
      exa:   [ 'E', 18 ],
      peta:  [ 'P', 15 ],
      tera:  [ 'T', 12 ],
      giga:  [ 'G', 9 ],
      mega:  [ 'M', 6 ],
      kilo:  [ 'k', 3 ],
      hecto: [ 'h', 2 ],
      deca:  [ 'da', 1 ],
      deci:  [ 'd', -1 ],
      centi: [ 'c', -2 ],
      milli: [ 'm', -3 ],
      micro: [ 'μ', -6 ],
      nano:  [ 'n', -9 ],
      pico:  [ 'p', -12 ],
      femto: [ 'f', -15 ],
      atto:  [ 'a', -18 ],
      zepto: [ 'z', -21 ],
      yocto: [ 'y', -24 ]
    }

    def self.expand_prefixes(unit_class, type)
      str = unit_class.instance.to_s
      classnames = PREFIXES.map do |prefix, (symbol, power)|
        classname = :"#{prefix.capitalize}#{unit_class.to_s.split('::').last.downcase}"
        Units.const_set(
          classname,
          Class.new(Unit.of(type)) do
            def to_s; @symbol; end
            def conversions; @conversions || {}; end
          end.tap do |cls|
            cls.instance.instance_variable_set(:@si_power, power)
            cls.instance.instance_variable_set(:@symbol, "#{symbol}#{str}")
          end
        )
        [ classname, power ]
      end

      unit_class.class_eval { attr_reader :conversions }
      unit_class.instance.instance_variable_set(:@si_power, 0)

      classnames.map(&:first).map(&Units.method(:const_get)).each do |cls|
        si_power = cls.instance.instance_variable_get(:@si_power) # kilo = 3
        cls.instance.instance_variable_set(
          :@conversions, 
          classnames.map do |(classname, power)| # hecto = 2
            [ Units.const_get(classname), {
              method_names: [ :"to_#{classname.downcase}s" ],
              conversion: proc { |number| number.fdiv(10**(power-si_power)) }
            } ]
          end.to_h
        )
      end
    end
  end
end
