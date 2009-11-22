module Dsl
  def self.included(base)
    base.extend ClassMethods
    
    base.instance_eval do
      include InstanceMethods
      alias_method_chain :method_missing, :block_support
    end
  end
  
  module ClassMethods
    def method_added(name)
      if name == :initialize && !@aliasing_initialize
        @aliasing_initialize = :prevent_skynet!
        alias_method_chain :initialize, :block_support
        remove_instance_variable :@aliasing_initialize
      end
    end
  end
  
  module InstanceMethods
    def initialize_with_block_support(*args, &block)
      initialize_without_block_support(*args)
      if block_given?
        @original_self = block.binding.eval("self")
        instance_eval(&block)
      end
      finish_init if defined?(:finish_init)
    end
    
    def method_missing_with_block_support(name, *args, &block)
      method_missing_without_block_support(name, *args, &block)
      
      if @original_self 
        @original_self.send(name, *args, &block)
      else
        super
      end
    end
  end
end