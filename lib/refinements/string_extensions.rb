class String
  # Useful only on a Mac.
  # Copies to your clipboard.
  def copy
    IO.popen('pbcopy', 'w') { |f| f << self }
  end

  def to_sql
    "'#{self}'"
  end
end
