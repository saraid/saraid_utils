module MemoizableMethods
  def self.included(base)
    base.extend(ClassMethods)
  end

  def memoize(calling_method = (caller.first =~ /`([^']*)'/ && $1).to_sym, &block)
    @memos ||= {}
    if @memos.key? calling_method
      @memos[calling_method]
    else
      @memos[calling_method] = yield
    end
  end

  module ClassMethods
    def memoize(symbol)
      original_method = "_unmemoized_#{symbol}".to_sym
      alias_method original_method, symbol
      define_method symbol do |*args, &block|
        memoize(symbol) do
          send(original_method, *args, &block)
        end
      end
    end
  end
end
