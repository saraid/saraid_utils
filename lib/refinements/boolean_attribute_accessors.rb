module BooleanAttributeAccessors
  def boolean_attr_reader(*names)
    names.each do |name|
      case name
      when Hash
        name.each do |positive, negative|
          boolean_attribute_reader(positive)
          negated_boolean_attribute_reader(negative, positive)
        end
      else
        boolean_attribute_reader(name)
      end
    end
  end

  def boolean_attr_writer(*names)
    names.each do |name|
      case name
      when Hash
        name.each do |positive, negative|
          boolean_attribute_writer(positive)
          boolean_attribute_writer(negative, positive, false)
        end
      else
        boolean_attribute_writer(name)
      end
    end
  end

  def boolean_attr_accessor(*names)
    boolean_attr_reader(*names)
    boolean_attr_writer(*names)
  end

  def boolean_attr(name, negate_as: nil)
    boolean_attribute_reader(name)
    negated_boolean_attribute_reader(negate_as, name) unless negate_as.nil?
    boolean_attribute_writer(name)
    boolean_attribute_writer(negate_as, name, false) unless negate_as.nil?
  end

  private def boolean_attribute_reader(name, varname = name)
    return if method_defined?(:"#{name}?")
    define_method(:"#{name}?") { instance_variable_get(:"@#{varname}") == true }
  end

  private def negated_boolean_attribute_reader(name, being_negated)
    return if method_defined?(:"#{name}?")
    define_method(:"#{name}?") { !send(:"#{being_negated}?") }
  end

  private def boolean_attribute_writer(name, varname = name, to_value = true)
    return if method_defined?(:"#{name}!")
    define_method(:"#{name}!") { instance_variable_set(:"@#{varname}", to_value) }
  end
end

module DemonstratingSaraidUtils
  class TestFoo
    extend BooleanAttributeAccessors

    boolean_attr_accessor :valid => :invalid
    boolean_attr_accessor :tbd, :initialized
    boolean_attr_accessor :done, :ready => :pending, :awesome => :terrible
    boolean_attr :fun, negate_as: :boring

    [:valid?, :invalid?, :tbd?, :initialized?, :done?, :ready?, :pending?, :awesome?, :terrible?, :fun?, :boring?].
      each { |m| instance_methods.include?(m) || (raise "#{m} is not defined and should be.") }
  end

  test = TestFoo.new
  test.valid!
  test.ready!
  test.awesome!
  test.boring!

  { :valid? => true,
    :invalid? => false,
    :ready? => true,
    :pending? => false,
    :awesome? => true,
    :terrible? => false,
    :fun? => false,
    :boring? => true
  }.each { |m, v| (test.send(m) == v) || (raise "#{m} is showing #{test.send(m)} rather than #{v}")}

end
