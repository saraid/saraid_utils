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

      unless ForwardCompatibility.instance_method_defined?(Hash, :transform_keys)
        refine Hash do
          def transform_keys
            map { |(key, value)| [ yield(key), value ] }.to_h
          end

          def transform_values
            map { |(key, value)| [ key, yield(value) ] }.to_h
          end
        end
      end

      # String#delete_prefix #delete_suffix
      # Array#prepend/append
      # Dir.children/each_child
    end

    module Ruby26
      unless ForwardCompatibility.instance_method_defined?(Object, :then)
        refine Object do
          alias then yield_self
        end
      end

      unless ForwardCompatibility.instance_method_defined?(Proc, :>>)
        refine Proc do
          def >>(other_proc)
            proc { |*args, &block| other_proc.call(self.call(*args, &block)) }
          end

          def <<(other_proc)
            proc { |*args, &block| self.call(other_proc.call(*args, &block)) }
          end
        end
      end

      unless ForwardCompatibility.instance_method_defined?(Enumerator, :chain)
        refine Enumerator do
          def chain(other)
            Enumerator.new { |y|
              self.each { |v| y.yield(v) }
              other.each { |v| y.yield(v) }
            }
          end

          alias :+ :chain
        end
      end

      # Hash#merge
      # Array#union, Array#difference
      # Range#%
    end

    module Ruby27
      unless ForwardCompatibility.instance_method_defined?(Enumerable, :tally)
        refine Array do
          def tally
            group_by(&:itself).transform_values(&:size)
          end
        end

        refine Hash do
          def tally
            to_a.tally
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
