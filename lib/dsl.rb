module Dsl
  def self.included(base)
    base.extend ClassMethods
    base.instance_eval { include InstanceMethods }
  end
  
  module ClassMethods    
    def method_added(name)      
      if !@_aliasing
        case name
        when :initialize, :method_missing
          @_aliasing = :prevent_skynet!
          alias_method_chain name, :block_support
          remove_instance_variable :@_aliasing
        end
      end
    end
  end
  
  module InstanceMethods
    def initialize_with_block_support(*args, &block)
      initialize_without_block_support(*args)
      if block_given?
        @_original_self = block.binding.eval("self")
        instance_eval(&block)
      end
      finish_init if defined?(:finish_init)
    end
    
    def method_missing_with_block_support(name, *args, &block)
      if method_missing_without_block_support(name, *args, &block) == :_super
        @_original_self ? @_original_self.send(name, *args, &block) : super
      end
    end
  end
end