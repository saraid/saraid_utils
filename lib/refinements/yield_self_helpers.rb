module YieldSelfHelpers
  def into(method_name, on: nil)
    yield_self(&(on.respond_to?(method_name) ? on.method(method_name) : method_name))
  end

  def parse_as_json
    require 'json'
    into(:parse, on: JSON)
  end

  def parse_as_uri
    require 'uri'
    into(:parse, on: URI)
  end

  def as_rest_resource
    require 'rest-client'
    RestClient::Resource.new(self,
                             user: ENV['SUPERADMIN_USER'],
                             password: ENV['SUPERADMIN_PASS'])
  end

  def unwrap_from_array
    is_a?(Array) ? unwrap : self
  end
end

class Object
  include YieldSelfHelpers if method_defined?(:yield_self)
end
