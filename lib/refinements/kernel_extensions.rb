module Kernel
  def require_stdlibs(*libs)
    libs.each(&Kernel.method(:require))
  end

  # For when you don't want a Bundler dependency.
  #
  # Usage:
  # require_gems(
  #   { ::activesupport => 'activesupport/core_ext/numeric/time' },
  #   'table_print',
  #   :rest-client
  # )
  def require_gems(*gems)
    missing_gems = gems.
      map { |gem| Hash === gem ? gem.keys : gem }.
      flatten.
      map(&:to_s).
      reject do |gem|
        Gem::Specification.all_names.any? { |name| name.start_with?(gem) }
      end

    unless missing_gems.empty?
      puts 'Gems missing. Please run:'
      puts '```'
      missing_gems.each do |gem|
        puts "  gem install #{gem}"
      end
      puts '```'
      raise LoadError, missing_gems.map(&:to_s)
    end

    gems.each do |gem|
      case gem
      when String, Symbol then require gem.to_s
      when Hash then gem.values.each(&Kernel.method(:require))
      end
    end
  end

  def read_from_stdin_or_pbpaste(verbose: false)
    require 'fcntl'

    if $stdin.fcntl(Fcntl::F_GETFL, 0).zero?
      $stderr.puts('Reading from STDIN') if verbose
      $stdin.read
    else
      $stderr.puts('Reading from clipboard') if verbose
      `pbpaste`
    end
  end
end
