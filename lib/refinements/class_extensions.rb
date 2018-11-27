class Class
  def chain_method(*methods)
    methods.each do |_method|
      unchained_method = :"_unchained_#{_method}"
      alias_method(unchained_method, _method)
      define_method(_method) do |*args, &block|
        send(unchained_method, *args, &block)
        self
      end
    end
  end
end
