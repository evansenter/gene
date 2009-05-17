module Calculator
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def generate_value(max)
      case max
      when 0:      raise(ArgumentError, "Trying to call Calculator.generate_value(0), which is not supported at this time due to ambiguity of intention")
      when Float:  rand(0)
      when Fixnum: rand(max)
      else         raise(ArgumentError, "Can't generate values of type #{max.class} in Calculator.generate_value(max)")
      end
    end
    
    def get_normal_random_variable
      x = y = sum = 0
      loop do
        x = get_uniform_random_variable
        y = get_uniform_random_variable
        break if (sum = (x ** 2) + (y ** 2)) < 1
      end
      rand(2).zero? ? convert(x, sum) : convert(y, sum)
    end
    
    def get_uniform_random_variable
      rand(0) * random_sign_change
    end
    
    private
  
    def random_sign_change
      rand(2).zero? ? 1 : -1
    end
  
    def convert(variable, sum)
      # http://en.wikipedia.org/wiki/Marsaglia_polar_method
      return 0 if sum.zero?
      variable * Math.sqrt(-2 * Math.log(sum) / sum)
    end
  end
end