# This is a simplification of ActiveSupport::Tryable
#

module Tryable
  def try(*args, &block)
    public_send(*args, &block) if respond_to? args.first
  end

  def try_any?(*methods)
    methods.any?(&method(:try))
  end

  def attempt(*args, &block)
    try(*args, &block) || self
  end
end

class Object
  include Tryable
end

class NilClass
  def try(*args)
    nil
  end

  def try_any?(*methods)
    nil
  end
end
