class Class
  def chain_method(*methods)
    methods.each do |_method|
      unchained_method = :"_unchained_#{_method}"
      alias_method(unchained_method, _method)
      define_method(_method) do |*args, &block|
        send(unchained_method, *args, &block)
        self
      end
    end
  end

  def boolean_attr_reader(*names)
    names.each do |name|
      case name
      when Hash
        name.each do |positive, negative|
          define_method(:"#{positive}?") { instance_variable_get(:"@#{positive}") == true }
          define_method(:"#{negative}?") { !send(:"#{positive}?") }
        end
      else
        define_method(:"#{name}?") { instance_variable_get(:"@#{name}") == true }
      end
    end
  end

  def boolean_attr_writer(*names)
    names.each do |name|
      case name
      when Hash
        name.each do |positive, negative|
          define_method(:"#{positive}!") { instance_variable_set(:"@#{positive}", true) }
          define_method(:"#{negative}!") { instance_variable_set(:"@#{positive}", false) }
        end
      else
        define_method(:"#{name}!") { instance_variable_set(:"@#{name}", true) }
      end
    end
  end

  def boolean_attr_accessor(*names)
    boolean_attr_reader *names
    boolean_attr_writer *names
  end
end

module DemonstratingSaraidUtils
  class TestFoo
    boolean_attr_accessor :valid => :invalid
    boolean_attr_accessor :tbd, :initialized
    boolean_attr_accessor :done, :ready => :pending, :awesome => :terrible

    [:valid?, :invalid?, :tbd?, :initialized?, :done?, :ready?, :pending?, :awesome?, :terrible?].
      each { |m| instance_methods.include?(m) || (raise "#{m} is not defined and should be.") }
  end
end
