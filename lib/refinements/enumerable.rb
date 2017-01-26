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

  def per_item_query(item, property, *args)
    if item.respond_to? property
      item.send(property, *args)
    elsif item.respond_to? :[]
      if args.empty?
        item[property]
      else
        properties = args.unshift(property)
        Hash[properties.zip(properties.collect { |prop| item[prop] })]
      end
    end
  end
  private :per_item_query

  def pluck(prop, *args)
    collect do |item|
      per_item_query(item, prop, *args)
    end
  end

  [
    :select, :filter, :find_all, :grep,
    :reject, :find, :detect, :all?, :any?
  ].each do |enumerable_method|
    is_predicate = enumerable_method.to_s =~ /\?$/
    method_name = enumerable_method.to_s.sub('?', '').+('_by')
    method_name += '?' if is_predicate

    define_method method_name.to_sym do |subquery, operator, value|
      comparator = lambda do |item|
        query_value = per_item_query(item, subquery)
        query_value.send(operator, value)
      end
      send(enumerable_method, &comparator)
    end
  end

  def search(value)
    comparator =
      case value
      when Regexp then lambda { |string| string.match value }
      when String then lambda { |string| string.include? value }
      else lambda { |string| string == value }
      end
    select(&comparator)
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

  def average
    sum.to_f/size
  end
  alias :avg :average

  def to_sentence
    case size
    when 0 then ''
    when 1 then self.first
    when 2 then join(' and ')
    else [0...-1].join(', ') + " and #{last}"
    end
  end

  def single?
    size == 1
  end

  def many?
    size > 1
  end

  def first_if_single
    first if single?
  end

  def map_then_puts(quiet = false, &block)
    require 'csv'
    results = map(&block)
    puts results.map(&:to_csv).join unless quiet
    results
  end

  def count_by(&block)
    group_by(&block).each_with_object({}) do |(key, value), memo|
      memo[key] = value.size
    end
  end

  # [ 192, 168, 0, 1..2 ] => [ '192.168.0.1', '192.168.0.2' ]
  def explode_by_combination(join_with = '.')
    parts = map { |part| part.respond_to?(:to_a) ? part.to_a.map(&:to_s) : [ part.to_s ] }
    combinations = parts.shift.map { |part| [ part ] }
    parts.inject(combinations) do |combos, part_values|
      combos.map { |combo| part_values.map { |part| combo + [ part ] } }.flatten(1)
    end.map do |combo|
      combo.join(join_with)
    end
  end

  def to_range(&block)
    sorted = block_given? ? self.sort_by(&block) : self.sort
    Range.new(sorted.first, sorted.last)
  end

  def map_to_hash(&block)
    map do |item|
      Hash.new.tap { |instance| instance.instance_exec(item, &block) }
    end
  end
end
