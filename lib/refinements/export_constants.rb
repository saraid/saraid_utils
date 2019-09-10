module ExportConstants
  def self.monkeypatch_module!
    Module.class_eval do
      def export_self_to_kernel!
        ExportConstants.export_constants!(self)
      end
    end
  end

  refine Module do
    def export_self_to_kernel!
      ExportConstants.export_constants!(self)
    end
  end

  def self.export_constants!(*constants)
    Array(constants).flatten.each do |klass|
      sym = klass.name.split('::').last.to_sym
      if Kernel.const_defined?(sym)
        raise "Collision on #{sym}" unless Kernel.const_get(sym) == klass
      else
        Kernel.const_set(sym, klass)
      end
    end
  end
end

# Expected usage 1:
# 
# module Namespace
#   module Foo
#     def self.yay!
#       'success'
#     end
#   end
#   ExportConstants.export_constants!([Foo])
# end
#
# Foo.yay!

# Expected usage 2:
#
# ExportConstants.monkeypatch_module!
#
# module Namespace
#   module Foo
#     export_self_to_kernel! if respond_to?(:export_self_to_kernel!)
#
#     def self.yay!
#       'success'
#     end
#   end
# end
#
# Foo.yay!
