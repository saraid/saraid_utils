module Enumerable
  def expand(&block)
    Hash[self.zip(self.collect(&block))]
  end

  def keep_if_as_expanded(*expansion, &block)
    self.
      expand { |item| item.send(*expansion) }.
      keep_if(&block).
      keys
  end

  def pluck(sym, *args)
    collect do |item|
      if item.respond_to? sym
        item.send(sym, *args)
      elsif item.respond_to? :[]
        item[sym]
      end
    end
  end

  def select_by_class(klass)
    select { |obj| klass === obj }
  end

  def detect_by_class(klass)
    detect { |obj| klass === obj }
  end

  def pick
    self[rand(size) - 1]
  end

  def sum
    inject(0) { |sum, n| sum + n }
  end

  def to_sentence
    case size
    when 0 then ''
    when 1 then self.first
    when 2 then join(' and ')
    else [0...-1].join(', ') + " and #{last}"
    end
  end
end
