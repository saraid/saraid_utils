require 'rest-client'

module Refinements
  module Endpoint
    DEFAULT_QUERY_COERCION = lambda do |query|
      next query if query.nil? # No query set. Just ignore.
      next query if query.kind_of?(String) # Param list built externally.
      raise ArgumentError unless query.respond_to?(:each) # wtf?

      query.map do |key, value|
        "#{key}=#{CGI.escape(value)}"
      end.join('&')
    end

    module ForwardCompatibility
      refine Hash do
        unless method_defined?(:slice)
          def slice(*args)
            dup.keep_if { |k, _| args.include?(k) }
          end
        end
      end

      refine Object do
        unless method_defined?(:yield_self)
          def yield_self
            yield self
          end
        end
      end
    end

    module RemoveIVarIfDefined
      refine Object do
        # Damn it, Ruby.
        def remove_instance_variable_if_defined(sym)
          remove_instance_variable(sym) if instance_variable_defined?(sym)
        end
      end
    end

    refine Module do
      using ForwardCompatibility
      using RemoveIVarIfDefined

      def endpoints_defined_as!(base_uri:, query_coercion: DEFAULT_QUERY_COERCION)
        if const_defined?(:Endpoint)
          const_get(:Endpoint).tap do |mod|
            mod.remove_instance_variable_if_defined(:@base_parts)
            mod.remove_instance_variable_if_defined(:@uri_class)
            mod.instance_variable_set(:@base_uri, base_uri)

            mod.define_singleton_method(:coerce_query_to_params, query_coercion)
          end
        else
          const_set(:Endpoint, Module.new do
            @base_uri = base_uri

            def self.build(name, hash = {})
              begin
                singleton_method(name)
                raise ArgumentError, "Method #{name} already exists on #{self}"
              rescue NameError
                define_singleton_method(name) do |*args|
                  hash = yield(*args) if block_given?
                  hash[:query] = coerce_query_to_params(hash[:query])

                  uri_options = hash.slice(*uri_components)
                  res_options = hash.slice(*(hash.keys - uri_components))
                  if res_options[:headers].is_a?(Array)
                    res_options[:headers] = res_options[:headers].reduce(:merge)
                  end

                  uri_class.
                    build(base_parts.merge(uri_options)).to_s.
                    yield_self { |uri| RestClient::Resource.new(uri, res_options) }
                end
              end
            end

            define_singleton_method(:coerce_query_to_params, query_coercion)
            private_class_method :coerce_query_to_params

            def self.host
              base_parts[:host]
            end

            def self.base_parts
              @base_parts ||= URI.parse(@base_uri).yield_self do |uri|
                { host: uri.host, port: uri.port }
              end
            end
            private_class_method :base_parts

            def self.uri_class
              @uri_class ||= URI.parse(@base_uri).class
            end
            private_class_method :uri_class

            def self.uri_components
              @uri_components ||= uri_class.const_get(:COMPONENT)
            end
            private_class_method :uri_components
          end)
        end
      end
    end
  end
end
