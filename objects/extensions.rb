def returning(value)
  yield value
  value
end

def add_bounding_methods_to(range)
  returning(range) do |object|
    object.instance_eval do
      def min
        self.begin.is_a?(Float) ? self.begin : super
      end
      
      def max
        self.end.is_a?(Float) ? self.end : super
      end
    end
  end
end

class Object
  def send_if(condition, method, *arguments)
    block = arguments.pop if arguments.last.is_a?(Proc) && arguments.length == 1
    if condition
      block ? eval("self.#{method} &block") : self.send(method, *arguments)
    else
      self
    end
  end
end

class Symbol
  def to_proc
    proc { |*args| args.first.send(self, *args[1..-1]) }
  end
  
  def [](object)
    object.method(self)
  end
  
  def []=(object, function)
    symbol = self
    eigenclass = (class << object; self; end)
    eigenclass.instance_eval { define_method(symbol, function) }
  end
  
  # def ax_b(a, b, *x)
  #   (:+[b] * :*[a]) | x
  # end
  # ax_b(2, 1, 1, 2, 3)
  # => [3, 5, 7]
end

class Module
  alias [] instance_method
  
  def []=(symbol, function)
    self.instance_eval { define_method(symbol, function) }
  end
end

class UnboundMethod
  alias [] bind
end