class Hash
  def deep_fetch(*args)
    found = self[args.shift]
    found = found.deep_fetch(*args) if found.respond_to?(:deep_fetch) && !args.empty?
    found
  end

  def count_values
    Hash[keys.zip(values.map(&:size))]
  end

  def bury(*to_bury, value)
    to_bury[0...-1].
      reduce(self) { |memo, layer| memo[layer] ||= self.class.new }.
      store(to_bury.last, value)
  end

  def only(*args)
    select { |k, _| args.include? k }
  end

  def except(*args)
    reject { |k, _| args.include? k }
  end

  def expand(&block)
    Hash[keys.zip(values.map(&block))]
  end

  def map_keys(&block)
    keys.map(&block).zip(values).to_h
  end

  def map_values(&block)
    keys.zip(values.map(&block)).to_h
  end
end
