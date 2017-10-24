class Hash
  def count_values
    Hash[keys.zip(values.map(&:size))]
  end

  def bury(*to_bury, value)
    to_bury[0...-1].
      reduce(self) { |memo, layer| memo[layer] ||= self.class.new }.
      store(to_bury.last, value)
  end

  def rummage(*tries, default: nil)
    begin
      case the_try = tries.shift
        when Array then dig(*the_try)
        else fetch(the_try)
      end
    rescue KeyError
      retry unless tries.empty?
      default
    end
  end
  alias seq_fetch rummage
  alias sequential_fetch rummage

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

  def paths_for_value(search)
    results = []
    each do |key, value|
      case value
      when Hash
        value.paths_for_value(search).each do |subpath|
          results << subpath.unshift(key)
        end
      else
        if case search
            when String then value.include?(search)
            when Regexp then value.match(search)
            else value == search
          end
          results << [key]
        end
      end
    end
    results
  end
end
