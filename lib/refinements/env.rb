# Theory:
# It is frustrating to use environment variables in scripts and not have good definitions for them.
# It is more frustrating to have to write giant comment blocks in order to explain how to get the
# environment variables you need.
#
# Trap:
# Environment variable names are deliberately normalized to all-caps, with underscores only.
# - Subject to change.
#
# Usage:
# When requesting a non-existent variable, you should be given a useful warning that indicates that
# the problem is related to a missing environment variable.
#
# ENV.fetch('MISSING_VAR')
# => script.rb:66:in `rescue in fetch': MISSING_VAR must be defined as an environment variable.
#
# You may also explain where to acquire values for your environment variables.
#
# require_environment_variables({
#   SECRET_PASSWORD: 'This is stored in our super secret vault of security.',
#   ROOT_PASSWORD: "It's on the sticky note in the server room. The key is under the doormat."
# })
#

# Define exception: EnvironmentVariableNotSet
proc do
  def initialize(key)
    @key = key
  end

  def to_s
    "#{@key} should be defined as an environment variable, but is not set."
  end
end.tap do |class_def|
  klass = Class.new(KeyError, &class_def)
  if defined?(RequiredEnvironmentVariablesMissing)
    ENV.instance_variable_set(:@missing_this_var, klass)
  else
    EnvironmentVariableNotSet = klass
    ENV.instance_variable_set(:@missing_this_var, EnvironmentVariableNotSet)
  end
  class << ENV
    attr_reader :missing_this_var
  end
end

# Define exception: RequiredEnvironmentVariablesMissing
proc do
  def initialize(hash)
    @missing = hash
  end

  def in_tty?
    STDOUT.tty? && STDERR.tty? && ENV['TERM'] != 'dumb'
  end

  def to_s
    $/ + @missing.map do |(var, desc)|
      if in_tty? then "\e[0m- \e[1m#{var}\e[0m: #{desc}"
      else "- #{var}: #{desc}"
      end
    end.join($/) + $/
  end
end.tap do |class_def|
  klass = Class.new(ArgumentError, &class_def)
  if defined?(RequiredEnvironmentVariablesMissing)
    ENV.instance_variable_set(:@missing_many_vars, klass)
  else
    RequiredEnvironmentVariablesMissing = klass
    ENV.instance_variable_set(:@missing_many_vars, RequiredEnvironmentVariablesMissing)
  end
  class << ENV
    attr_reader :missing_many_vars
  end
end

# All the monkeypatching!
if ENV.method(:fetch).source_location.nil?
  class << ENV
    attr_writer :logger

    def logger
      @logger ||=
        begin
          require 'logger'
          Logger.new(STDERR)
        end
    end

    def require_environment_variables(vars = {})
      if vars.respond_to?(:transform_keys)
        vars.transform_keys!(&method(:normalize_key))
      else
        vars = vars.map { |(key, value)| [ normalize_key(key), value ] }.to_h
      end
      (@required ||= []).concat(vars.keys)

      missing = vars.reject { |var, desc| key?(var) }
      return if missing.empty?
      raise missing_many_vars.new(missing)
    end

    alias original_fetch fetch
    def fetch(*args, &block)
      key = normalize_key(args.shift)
      original_fetch(key, *args, &block)
    rescue KeyError => e
      raise missing_this_var.new(key)
    end

    def [](key)
      fetch(key, nil)
    end

    private def normalize_key(key)
      key.to_s.upcase.gsub(/[^A-Z0-9]/, '_').squeeze('_')
    end
  end

  # Put this in at the top level.
  module Kernel
    def require_environment_variables(vars)
      ENV.require_environment_variables(vars)
    end
  end
else
  puts '[ENV MonkeyPatching] Something else has monkeypatched ENV already. Bailing out.'
end
