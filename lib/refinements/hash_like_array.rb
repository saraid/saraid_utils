# Usage:
#
# my_ary = [ { a: :foo, b: :bar, c: :baz },
#            { a: :erf, b: :drf, c: :srf },
#            { a: :lol, b: :omg, c: :wat }
#          ].access_by(:a)
# my_ary[:foo] #=> { a: :foo, b: :bar, c: :baz }
#

module Refinements 
  module HashLikeArray
    refine Array do
      using Refinements::ForwardCompatibility::Ruby25

      def access_by(key)
        unless defined?(@_accessed_by)
          singleton_class.class_eval do
            def [](access_key)
              find { |item| item&.[](@_accessed_by) == access_key } || super(access_key)
            end

            def fetch(*args, &block)
              raise ArgumentError unless args.first.size == 1
              key, value = args.first.to_a.first
              find { |item| item&.[](key) == value }.
                yield_self do |found|
                  next found unless found.nil?
                  next args[1] if args.size == 2
                  if block_given?
                    yield(key)
                  else
                    raise KeyError, "#{key}:#{value} was not found"
                  end
                end
            end
          end
        end

        @_accessed_by = key
        self
      end
    end
  end
end

module DemonstratingSaraidUtils
  using Refinements::HashLikeArray

  class << self
    attr_reader :hash_like_array
  end

  @hash_like_array = [
    { key: :foo,
      other_key: :bar
    },
    { key: :superman,
      other_key: :batman
    }
  ].access_by(:key)

  [ hash_like_array[:foo] == { key: :foo, other_key: :bar },
    hash_like_array.fetch({other_key: :batman}) == { key: :superman, other_key: :batman }
  ].all?
end
