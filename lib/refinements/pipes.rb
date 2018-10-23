module Pipes
  def chain_method
    self
  end

  condition_interpreter = lambda do |condition|
    if condition.respond_to?(:call) then condition.call
    elsif self.respond_to?(condition) then self.send(condition)
    else condition
    end
  end

  def if(condition)
    condition_met = condition_interpreter.call(condition)
    if condition_met then yield else chain_method end
  end

  def unless(condition, &block)
    self.if(!condition_interpreter.call(condition), &block)
  end

  def if_nil(&block)
    self.if(:nil?, &block)
  end

  def nil_if(&block)
    self.if(block) { nil }
  end
end

class Object
  include Pipes
end

# Demo:
#
# some_list.
#   find(&some_criteria).
#   if_nil { raise 'not found' }.
#   yield_self(&do_stuff)
