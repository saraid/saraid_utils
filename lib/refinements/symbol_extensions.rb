class Symbol
  def call(*args, &block)
    ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
  end

  def as_method
    call
  end
  alias to_method as_method
end
