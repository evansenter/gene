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

class Symbol
  def to_proc
    proc { |*args| args.first.send(self, *args[1..-1]) }
  end
end

class Object
  # Not tested.
  def send_if(condition, method, *args)
    block = args.shift if args.last.is_a?(Proc) && args.length == 1
    if condition
      block ? eval("self.#{method} &block") : self.send(method, *args)
    else
      self
    end
  end
end