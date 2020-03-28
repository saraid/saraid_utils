module Slack
  module Messages
    module Blocks
      class TypeRestrictedArray < Array
        undef_method :concat, :[]= # Surely never necessary lol

        def initialize(*classes)
          @classes = classes
        end

        def <<(item)
          raise TypeError, "#{self.class} only accepts #{@classes}" unless @classes.any? { |cls| item.kind_of?(cls) }
          super(item)
        end
      end
    end
  end
end
