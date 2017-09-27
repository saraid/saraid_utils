require 'singleton'

class ModuleClass < Module
  include ::Singleton

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
