class Symbol
  def call(*args, &block)
    ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
  end

  # case SomeObject
  # when :foo.to_method then :foo
  # when :bar.to_method(:baz) then :barbaz
  # end
  def to_method(*args, &block)
    proc { |obj| obj.send(self, *args, &block) }
  end
end
