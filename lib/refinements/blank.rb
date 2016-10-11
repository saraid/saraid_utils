# This is a simplification of ActiveSupport::Blankable
#

module Blankable
  def blank?
    respond_to?(:empty?) ? empty? : nil?
  end
end

class Object
  include Blankable
end
