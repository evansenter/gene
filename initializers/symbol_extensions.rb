module SymbolExtensions
  def [](object)
    object.method(self)
  end

  def []=(object, function)
    symbol = self
    eigenclass = (class << object; self; end)
    eigenclass.instance_eval { define_method(symbol, function) }
  end
end

class Symbol; include SymbolExtensions; end