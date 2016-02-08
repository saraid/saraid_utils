module CacheableMethods
  def cache(options = {}, &block)
    timeout = options[:timeout] ||= 5.minutes
    calling_method = options[:calling_method] ||= (caller.first =~ /`([^']*)'/ && $1).to_sym

    @cached_values ||= {}
    @cached_values.fetch(calling_method, {})[:timeout].try(:<, Time.now)
    not_cached = [
      !@cached_values[calling_method],
      @cached_values.fetch(calling_method, {})[:timeout].try(:<, Time.now)
    ].any?

    if not_cached
      @cached_values[calling_method] = { value: yield, timeout: Time.now + timeout }
    end
    @cached_values[calling_method][:value]
  end
end
