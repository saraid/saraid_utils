module WrapIntoClass
  @class_wrappers ||= {}

  def self.[](identifier)
    @class_wrappers[identifier]
  end

  # Do not cache nil identifiers.
  def self.[]=(identifier, wrapper)
    @class_wrappers[identifier] = wrapper unless identifier.nil?
  end

  refine Object do
    def wrap_into_class(identifier = nil, *args, &block)
      (WrapIntoClass[identifier] ||=
        begin
          Class.new do
            def initialize(wrapped)
              @wrapped = wrapped
            end

            def unwrap
              @wrapped
            end

            def respond_to_missing?(id, include_private = false)
              super || @wrapped.respond_to?(id, include_private)
            end

            def method_missing(id, *args, &block)
              @wrapped.send(id, *args, &block)
            end
          end.
          tap { |wrapper_class| wrapper_class.class_eval(&block) }.
          tap { |wrapper_class| WrapIntoClass[identifier] = wrapper_class unless identifier.nil? }
        end
      ).new(self, *args)
    end
  end
end

module DemonstratingSaraidUtils
  using WrapIntoClass

  def self.passing_the_threshold
    rand.wrap_into_class(:foo, :>=) do
      def initialize(wrapped, comparison_method)
        @wrapped = wrapped
        @comparison_method = comparison_method
      end

      def ==(other)
        puts @wrapped
        @wrapped.send(@comparison_method, other)
      end
    end
  end
end
