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

    def inspect
      postamble = " #{to_s.to_sym.inspect}" unless to_s.start_with?(' ')
      "#<#{self.class}:#{'0x%x' % (object_id << 1)}#{postamble}>"
    end

    def format(number)
      [number, to_s].join
    end

    def conversions
      {}
    end

    def can_convert_to?(unit)
      conversions.key?(unit) || conversions.key?(unit.class)
    end

    def convert(unit)
      raise ArgumentError, 'cannot convert between different types' unless unit.type == type
      conversions[unit.class][:conversion]
    end
  end
end
