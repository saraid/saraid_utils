class Symbol
  def call(*args, &block)
    ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
  end
  alias as_method call
  alias to_method call

  def ===(other)
    self == other || other.respond_to?(self) && other.send(self)
  end
end
