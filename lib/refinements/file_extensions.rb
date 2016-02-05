class File
  def self.[](path, mode = 'r')
    file_handle = nil
    [
      lambda { |path| path },
      lambda { |path| File.expand_path(path) },
      lambda { |path| File.join(Dir.pwd, path) }
    ].each do |strategy|
      break if file_handle
      filename = strategy.call(path)
      file_handle = File.open(filename, mode) if File.exists? filename
    end
    file_handle
  end
end

