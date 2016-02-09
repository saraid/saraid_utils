module CacheableMethods
  def cache(options = {}, &block)
    timeout = options[:timeout] ||= 5.minutes
    cache_key = options[:cache_key] ||= (caller.first =~ /`([^']*)'/ && $1).to_sym

    @cached_values ||= {}
    not_cached = [
      !@cached_values[cache_key],
      @cached_values.fetch(cache_key, {})[:timeout].try(:<, Time.now)
    ].any?

    if not_cached
      @cached_values[cache_key] = { value: yield, timeout: Time.now + timeout }
    end
    @cached_values[cache_key][:value]
  end

  def cached?(method)
    @cached_values ||= {}
    @cached_values.fetch(method, {})[:timeout].try(:>, Time.now).to_bool
  end
end
