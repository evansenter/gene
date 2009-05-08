module Functional
  # sum = lambda { |x, y| x + y }
  # sum | [[1, 2], [3, 4]]
  # => [3, 7]
  def apply(enum)
    enum.map &self
  end
  alias | apply
  
  # sum = lambda { |x, y| x + y }
  # sum <= [1, 2, 3, 4]
  # => 10
  def reduce(enum)
    enum.inject &self
  end
  alias <= reduce
  
  # add_1  = lambda { |x| x + 1 }
  # double = { |x| x * 2 }
  # (add_1 * double)[2]
  # => 5
  # (double * add_1)[2]
  # => 6
  def compose(function)
    if self.respond_to?(:arity) && self.arity == 1
      lambda { |*args| self[function[*args]] }
    else
      lambda { |*args| self[*function[*args]] }
    end
  end
  alias * compose
  
  # function = lambda { |x, y, z| x * y + z }
  # (function >> 5)[4, 4]
  # => 24
  def apply_head(*first)
    lambda { |*rest| self[*first.concat(rest)] }
  end
  alias >> apply_head
  
  # function = lambda { |x, y, z| x * y + z }
  # (function << 5)[4, 4]
  # => 21
  def apply_tail(*last)
    lambda { |*rest| self[*rest.concat(last)] }
  end
  alias << apply_tail
  
  # factorial = +lambda { |x| x == 1 ? 1 : x * factorial[x - 1] }
  # factorial[5]
  # => 120
  def memoize
    cache = {}
    lambda do |*args|
      unless cache.has_key?(args)
        cache[args] = self[*args]
      end
      cache[args]
    end
  end
  alias +@ memoize
  
  # array     = [2, 3, 4, 5, 6, 7, 8, 9]
  # sum       = lambda { |x, y| x + y }
  # square    = lambda { |x| x * x }
  # mean      = (sum <= a) / a.size.to_f
  # deviation = lambda { |x| x - mean }
  # 
  # standard_deviation = Math.sqrt((sum <= square * deviation | a) / (a.size - 1))
end

class Method; include Functional; end
class Proc; include Functional; end

class Symbol
  # [1, 2, 3].map(&:to_s)
  #   => ["1", "2", "3"]
  def to_proc
    lambda { |receiver, *args| receiver.method(self)[*args] }
  end
  
  # dashes = :*["-"]
  # dashes[10]
  # => "----------"
  def [](object)
    object.method(self)
  end
  
  # string = "Hello world."
  # :singleton[string] = lambda { p "You have found my singleton method." }
  # string.singleton
  # => "You have found my singleton method."
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
  # String[:reverse]
  # => #<UnboundMethod: String#reverse>
  alias [] instance_method
  
  # String[:backwards] = lambda { reverse }
  # "sideways".backwards
  # => "syawedis"
  def []=(symbol, function)
    self.instance_eval { define_method(symbol, function) }
  end
end

class UnboundMethod
  # String[:reverse]["sideways"][]
  # => "syawedis"
  alias [] bind
end