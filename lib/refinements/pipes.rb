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

  def if(condition, or_else: nil)
    or_else = chain_method if or_else.nil?
    condition_met = condition_interpreter.call(condition)
    if condition_met then yield else or_else end
  end

  def unless(condition)
    self.if(!condition_interpreter.call(condition))
  end

  def if_nil(or_else: nil, &block)
    self.if(:nil?, or_else: or_else, &block)
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
