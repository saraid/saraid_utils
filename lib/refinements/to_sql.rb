# Modify the Object class to have two translation methods.
# * #to_sql translates the object into a single-quoted string.
class Object
  def to_sql
    "'#{self}'"
  end
end

class Numeric
  def to_sql
    "#{self}"
  end
end

# nil is represented as NULL in SQL, without single quotes.
class NilClass
  def to_sql
    'NULL'
  end
end

# true is represented as true in SQL, without single quotes.
class TrueClass
  def to_sql
    'true'
  end
end

# false is represented as false in SQL, without single quotes.
class FalseClass
  def to_sql
    'false'
  end
end

module SaraidSql
  class MultiRowUpdate
    def initialize(data, options)
      @data = data
      @options = options
    end
    attr_reader :data, :options

    def to_sql
      return nil if data.empty?
      value_column_name = options.fetch(:value_column_name)
      key_column_name = options.fetch(:key_column_name)
      value_column_value = options.fetch(:value_column_value, proc { |datum| datum.send(value_column_name.to_sym) })
      key_column_value = options.fetch(:key_column_value, proc { |datum| datum.send(key_column_name.to_sym) })
      comment = options.fetch(:comment, proc {})
      cases = data.map do |datum|
        [ "WHEN #{key_column_value.call(datum).to_sql}",
          "THEN #{value_column_value.call(datum).to_sql}",
          "-- #{comment.call(datum)}"
        ].join(' ')
      end.map { |string| ' '*5 + string }.unshift(nil)
      <<~SQL
        UPDATE #{options.fetch(:table)}
           SET #{value_column_name} = CASE #{key_column_name}#{cases.join($/)}
             ELSE #{value_column_name}
             END
         WHERE #{key_column_name} IN (#{data.map(&key_column_value).map(&:to_sql).join(', ')});
      SQL
    end
  end
end
