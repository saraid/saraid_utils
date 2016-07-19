class File
  def self.guess(path, mode = 'r', &block)
    filename = [
      lambda { |path| path },
      lambda { |path| File.expand_path(path) },
      lambda { |path| File.join(Dir.pwd, path) }
    ].collect { |strategy| strategy.call(path) }.
      detect(&File.method(:exists?))
    File.open(filename, mode, &block) if filename
  end

  # This should really be a unit test.
  # 'foo' => 'foo.2'
  # 'foo.2' => 'foo.3'
  # 'foo.csv' => 'foo.2.csv'
  # 'foo.2.csv' => 'foo.3.csv'
  def self.increment(path, mode = 'w', &block)
    while File.exists? path
      parts = path.split('.')
      if /\d+/ =~ parts[-1]
        parts[-1] = parts[-1].succ
      elsif /\d+/ =~ parts[-2]
        parts[-2] = parts[-2].succ
      elsif parts.size > 1
        parts.insert(-2, '2')
      elsif parts.size == 1
        parts.insert(-1, '2')
      end

      path = parts.join('.')
    end
    File.open(path, mode, &block)
  end

  def self.read_json(path)
    JSON.parse(File.read(path))
  end
end
