module ClassAttributeDefiners
  def class_attribute(symbol)
    self.class.instance_eval do
      define_method "#{symbol}?".to_sym do
        !!instance_variable_get("@#{symbol}".to_sym)
      end

      define_method "#{symbol}!".to_sym do
        instance_variable_set("@#{symbol}".to_sym, true)
      end
    end
  end

  def class_attributes(*ary)
    ary.flatten.each(&method(:class_attribute))
  end
end
