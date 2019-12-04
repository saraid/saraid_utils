module URI
  class Generic
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
