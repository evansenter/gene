class Dsl
  def initialize(*args, &block)
    if block_given?
      @_original_self = block.binding.eval("self")
      instance_eval(&block)
      remove_instance_variable :@_original_self
    end
    finish_init if defined? :finish_init
  end
  
  def method_missing(name, *args, &block)
    @_original_self ? @_original_self.send(name, *args, &block) : super
  end
end