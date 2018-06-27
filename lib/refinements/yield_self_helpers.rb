module YieldSelfHelpers
  def parse_as_json
    require 'json'
    yield_self(&JSON.method(:parse))
  end

  def parse_as_uri
    require 'uri'
    yield_self(&URI.method(:parse))
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
