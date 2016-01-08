# This is a simplification of ActiveSupport::Tryable
#

module Tryable
  def try(*args, &block)
    public_send(*args, &block) if respond_to? args.first
  end
end

class Object
  include Tryable
end

class NilClass
  def try(*args)
    nil
  end
end
