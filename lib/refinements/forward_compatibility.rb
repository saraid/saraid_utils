module Refinements
  module ForwardCompatibility
    def self.instance_method_defined?(klass, method)
      begin
        klass.instance_method(method)
        true
      rescue NameError
        false
      end
    end

    module Ruby24
      unless ForwardCompatibility.instance_method_defined?(Regexp, :match?)
        refine Regexp do
          def match?(*args, &block)
            !!match(*args, &block)
          end
        end
      end

      unless ForwardCompatibility.instance_method_defined?(String, :match?)
        refine String do
          def match?(*args, &block)
            !!match(*args, &block)
          end
        end
      end
    end

    module Ruby25
      unless ForwardCompatibility.instance_method_defined?(Object, :yield_self)
        refine Object do
          def yield_self
            yield self
          end
        end
      end

      # String#delete_prefix #delete_suffix
      # Array#prepend/append
      # Hash#transform_keys/values
      # Dir.children/each_child
    end

    module Ruby26
      # Proc composition
      # Enumerable#chain
      # Hash#merge
      # Array#union, Array#difference
      # Range#%
    end

    module Ruby27
      unless ForwardCompatibility.instance_method_defined?(Enumerable, :tally)
        refine Array do
          def tally
          end
        end

        refine Hash do
          def tally
          end
        end
      end
    end

    include Ruby24
    include Ruby25
    include Ruby26
    include Ruby27
  end
end
