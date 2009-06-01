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
end

class Method; include Functional; end
class Proc; include Functional; end