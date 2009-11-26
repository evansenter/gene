class Module
  alias [] instance_method

  def []=(symbol, function)
    self.instance_eval { define_method(symbol, function) }
  end

  def alias_method_chain(target, feature)
    method_name, extension = target.to_s.match(/(\w+)(\W?)/).to_a[1..-1]
    
    alias_method "#{method_name}_without_#{feature}#{extension}", target
    alias_method target, "#{method_name}_with_#{feature}#{extension}"
  end
end