def returning(value)
  yield value
  value
end

def add_bounding_methods_to(range)
  returning(range) do |object|
    def object.max
      self.end.is_a?(Float) ? self.end : super
    end
  
    def object.min
      self.begin.is_a?(Float) ? self.begin : super
    end
  end
end

class Symbol
  def to_proc
    proc { |*args| args.first.send(self, *args[1..-1]) }
  end
end