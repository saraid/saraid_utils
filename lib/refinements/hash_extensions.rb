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

  def flatten
    recursor = lambda do |layer, cursor, path_collection = {}|
      layer.each do |path_part, new_layer|
        path_parts = cursor + [path_part]
        value = dig(*path_parts)
        if value.is_a?(Hash)
          recursor.call(new_layer, path_parts, path_collection)
        else
          path_collection[path_parts.dup] = value unless value.is_a?(Hash)
        end
      end
      path_collection
    end
    recursor.call(self, [])
  end
end
