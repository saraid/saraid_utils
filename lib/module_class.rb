require 'singleton'

module ModuleClassMixin
  def self.included(mod)
    mod.include(::Singleton)
    mod.define_singleton_method(:respond_to_missing?) do |id, include_private = false|
      instance.respond_to?(id, include_private) || super
    end
    mod.define_singleton_method(:method_missing) do |id, *args, &block|
      return instance.public_send(id, *args, &block) if instance.respond_to?(id)
      super
    end
  end
end

class AbstractModuleClass
  def self.inherited(mod)
    mod.include(::Singleton)
    mod.define_singleton_method(:respond_to_missing?) do |id, include_private = false|
      instance.respond_to?(id, include_private) || super
    end
    mod.define_singleton_method(:method_missing) do |id, *args, &block|
      return instance.public_send(id, *args, &block) if instance.respond_to?(id)
      super
    end
  end
end
