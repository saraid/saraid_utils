module SaneInspection
  def self.monkeypatch_module!
    Module.class_eval do
      def classes_beneath_namespace
        constants.select { |const| const_get(const).class == Class }.map(&method(:const_get))
      end

      def all_classes_beneath_namespace
        (classes_beneath_namespace + classes_beneath_namespace.map(&:classes_beneath_namespace)).flatten
      end
    end
  end

  def self.saneify_inspect_on_every_class!(mod)
    monkeypatch_module! unless mod.respond_to?(:all_classes_beneath_namespace)
    mod.all_classes_beneath_namespace.each(&SaneInspection.method(:saneify_inspect!))
  end

  def self.saneify_inspect!(mod)
    mod.class_eval do
      def inspect
        properties = if respond_to?(:inspectable_attributes)
          inspectable_attributes.
            map { |attr| "@#{attr}=#{instance_variable_get(:"@#{attr}").inspect}" }.
            join(', ').
            prepend(' ')
        else ''
        end
        "#<#{self.class}:#{'0x%x' % (object_id << 1)}#{properties}>"
      end
    end
  end
end

# Expected usage:
#
# module SomeMod
# end
#
# class SomeMod::SomeClass
# end
#
# SaneInspection.saneify_inspect_on_every_class!(SomeMod)
