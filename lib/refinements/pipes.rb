module Pipes
  def chain_method
    self
  end

  def self.condition_interpreter(receiver, condition)
    if Symbol === condition && receiver.respond_to?(condition) then receiver.send(condition)
    elsif condition.respond_to?(:call) then condition.call
    else condition
    end
  end

  def if(condition)
    condition_met = Pipes.condition_interpreter(self, condition)
    if condition_met then yield self else chain_method end
  end

  def unless(condition, &block)
    self.if(!Pipes.condition_interpreter(self, condition), &block)
  end

  def if_nil(&block)
    self.if(:nil?, &block)
  end

  def nil_if(&block)
    self.if(block) { nil }
  end

  if Regexp.method_defined?(:match?)
    def if_match(regex, &block)
      self.if(regex.match?(self), &block)
    end
  else
    def if_match(regex, &block)
      self.if(!!regex.match(self), &block)
    end
  end
end

class Object
  include Pipes
end

module DemonstratingSaraidUtils
  module Pipes
    def self.run
      [ lambda { '123'.if_match(/\d+/, &:to_i) == 123 },
        lambda { [1, 3].find(&:even?).if_nil { 'sigh' } == 'sigh' },
        lambda { nil.if(:nil?) { true } == true },
        lambda { nil.unless(:nil?) { true } == nil }
      ].map(&:call).all?
    end
  end
end

# Demo:
#
# some_list.
#   find(&some_criteria).
#   if_nil { raise 'not found' }.
#   yield_self(&do_stuff)
