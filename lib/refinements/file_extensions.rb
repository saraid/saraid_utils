class File
  def self.guess(path, mode = 'r')
    filename = [
      lambda { |path| path },
      lambda { |path| File.expand_path(path) },
      lambda { |path| File.join(Dir.pwd, path) }
    ].collect { |strategy| strategy.call(path) }.
      detect(&File.method(:exists?))
    File.open(filename, mode) if filename
  end
end
