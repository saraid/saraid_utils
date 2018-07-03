class Object
  def yield_self
    yield self
  end
end

class Regexp
  def to_class(superclass = Object, &block)
    new_class = Class.new(superclass)
    new_class.const_set(:REGEX, self)
    new_class.class_eval do
      def self.processors
        @processors || {}
      end

      def self.process(**options)
        options.each do |key, value|
          value = String.instance_method(value) if String.method_defined?(value)
          raise ArgumentError unless value.respond_to?(:call) || value.respond_to?(:bind)
          (@processors ||= {})[key.to_sym] = value
        end
      end

      def initialize(some_string)
        regex = self.class.const_get(:REGEX)
        match = regex.match(some_string)
        raise ArgumentError, "must conform to #{regex}" if match.nil?

        regex.names.each do |name|
          capture = match[name]
          if self.class.processors.key?(name.to_sym)
            processor = self.class.processors[name.to_sym]

            capture = 
              if processor.respond_to?(:call)
                processor.call(capture)
              else
                processor.bind(capture).call
              end
          end
          instance_variable_set(:"@#{name}", capture)
        end
      end

      attr_reader *const_get(:REGEX).names
    end
    new_class.class_eval(&block) if block_given?
    new_class
  end
end

module DemonstratingSaraidUtils; end
DemonstratingSaraidUtils.const_set(:Status,
  /(?<status>\d+)/.to_class do
    process status: :to_i
  end)
DemonstratingSaraidUtils::Status.new('123')
