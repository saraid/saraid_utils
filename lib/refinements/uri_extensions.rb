module URI
  def self.parse_without_scheme(unparsed, scheme:)
    case scheme
    when String, Symbol then scheme
    when ->(x){ x < URI::Generic } then URI.scheme_list.invert.fetch(scheme, '').downcase
    else raise ArgumentError, 'passed scheme not understood'
    end
      .yield_self { |deduced_scheme| URI.parse("#{deduced_scheme}://#{unparsed}") }
  end

  class HTTP
    def self.parse(unparsed)
      scheme, *parts = URI.split(unparsed)

      if scheme.nil?
        scheme = URI.scheme_list.invert.fetch(self).downcase
        URI.parse("#{scheme}://#{unparsed}")
      else
        URI.parse(unparsed).tap do |uri|
          raise InvalidURIError, "bad URI(claimed #{self} but was #{uri.class}" unless self === uri
        end
      end
    end
  end
end
