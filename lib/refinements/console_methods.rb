module ConsoleMethods
  def pbcopy(string)
    string.to_s.copy
  end

  def pbpaste
    `pbpaste`.chop
  end
  alias :paste :pbpaste

  def open_url(url)
    `open #{url.to_s}`
  end

  def benchmark
    time_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    puts "#{Process.clock_gettime(Process::CLOCK_MONOTONIC) - time_start} seconds."
  end
end
