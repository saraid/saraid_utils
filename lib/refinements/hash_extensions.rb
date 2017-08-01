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

  def domino(*tries, default: nil)
    begin
      fetch(tries.shift)
    rescue KeyError
      retry unless tries.empty?
      default
    end
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

  if Object.new.respond_to?(:blank?)
    def compact
      reject { |_, v| v.blank? }
    end
  else
    def compact
      reject { |_, v| v.nil? }
    end
  end

  def map_keys(&block)
    keys.map(&block).zip(values).to_h
  end

  def map_values(&block)
    keys.zip(values.map(&block)).to_h
  end

  # Suggested usage:
  # { foo: { bar: 1 }}.flatten.map_keys(&:join.call('.'))
  # => { "foo.bar" => 1 }
  #
  # This overrides Enumerable#flatten, which may or may not be a bad thing.
  # Also see: https://stackoverflow.com/questions/9647997/converting-a-nested-hash-into-a-flat-hash
  def flatten
    recursor = lambda do |layer, cursor, path_collection = {}|
      layer.each do |path_part, new_layer|
        path_parts = cursor + [path_part]
        value = dig(*path_parts)
        if value.respond_to?(:dig)
          recursor.call(new_layer, path_parts, path_collection)
        else
          path_collection[path_parts.dup] = value
        end
      end
      path_collection
    end
    recursor.call(self, [])
  end
end
