require 'singleton'

class ModuleClass < Module
  include ::Singleton

  def self.respond_to_missing?(id, include_private = false)
    instance.respond_to?(id, include_private) || super
  end

  def self.method_missing(id, *args, &block)
    return instance.public_send(id, *args, &block) if instance.respond_to?(id)
    super
  end
end

class Example < ModuleClass
  def foo
    'hi'
  end

  def yar
    object_id
  end
end

Example.foo #=> 'hi'
100.times.map { Example.yar }.uniq.size #=> 1

#require 'singleton'
#require 'forwardable'
#
#class ModuleClass2 < Module
#  include ::Singleton
#
#  def self.inherited(subclass)
#    subclass.extend(::Forwardable)
#    subclass.def_delegators :instance, *(subclass.instance_methods - self.instance_methods)
#  end
#end
#
#class Example2 < ModuleClass2
#  def foo
#    'hi'
#  end
#end

require 'singleton'

module ModuleClass3
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

class Example3 < Hash
  include ModuleClass3

  def foo
    'hi'
  end

  def yar
    object_id
  end
end
