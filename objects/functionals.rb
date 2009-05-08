module Functional
  def apply(enum)
    enum.map &self
  end
  alias | apply
  
  def reduce(enum)
    enum.inject &self
  end
  alias <= reduce
  
  def compose(function)
    if self.respond_to?(:arity) && self.arity == 1
      lambda { |*args| self[function[*args]] }
    else
      lambda { |*args| self[*function[*args]] }
    end
  end
  alias * compose
  
  def apply_head(*first)
    lambda { |*rest| self[*first.concat(rest)] }
  end
  alias >> apply_head
  
  def apply_tail(*last)
    lambda { |*rest| self[*rest.concat(last)] }
  end
  alias << apply_tail
  
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