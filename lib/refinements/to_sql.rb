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
