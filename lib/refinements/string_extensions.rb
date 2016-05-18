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
end
