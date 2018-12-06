# encoding: UTF-8

class String
  # Useful only on a Mac.
  # Copies to your clipboard.
  def copy
    IO.popen('pbcopy', 'w') { |f| f << self }
  end

  def lstrip!
    sub! /^[\s ]+/, ''
  end

  def rstrip!
    sub! /[\s ]+$/, ''
  end

  def only_whitespace?
    /^[\s ]+$/.match(self).to_bool
  end

  def only_whitespace_or_empty?
    empty? || only_whitespace?
  end

  def levenshtein_distance(other)
    m, n = self.length, other.length
    return m if n == 0
    return n if m == 0

    # Create our distance matrix
    d = Array.new(m+1) {Array.new(n+1)}
    0.upto(m) { |i| d[i][0] = i }
    0.upto(n) { |j| d[0][j] = j }

    1.upto(n) do |j|
      1.upto(m) do |i|
        d[i][j] = self[i-1] == other[j-1] ? d[i-1][j-1] : [d[i-1][j]+1,d[i][j-1]+1,d[i-1][j-1]+1,].min
      end
    end
    d[m][n]
  end

  def closest_match(array)
    array.min_by(&method(:levenshtein_distance))
  end

  def wrap(before, after = nil)
    prepend(before)
    self << (after || before)
  end
  alias :inpend :wrap

  def to_pathname
    require 'pathname'
    Pathname.new(File.expand_path(self))
  end
end
