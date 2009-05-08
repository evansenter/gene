require File.join("#{File.dirname(__FILE__)}", "extensions/extensions.rb")

class Trait
  include Calculator
  
  STANDARD_DEVIATION = {
    :default => 0.1,
    :range   => add_bounding_methods_to((0.01..0.25))
  }
  
  attr_reader :value, :range, :standard_deviation
  
  def initialize(name, range, options = {})
    @range              = add_bounding_methods_to(range)
    @standard_deviation = setup_standard_deviation_with(options[:standard_deviation])
    @value              = setup_value_with(options[:default])
    
    name[self] = lambda { @value }
  end
  
  def setup_standard_deviation_with(standard_deviation)
    (standard_deviation || STANDARD_DEVIATION[:default]) * @range.max
  end
  
  def setup_value_with(value)
    if value && !range.include?(value)
      raise(ArgumentError, "Can't generate a trait with a default value (#{value}) outside the allowed range (#{@range})")
    else
      value || Calculator.generate_value(@range.max)
    end
  end
  
  def mutated_value
    new_value = @value + @standard_deviation * Calculator.get_uniform_random_variable
    new_value = new_value.round if @value.is_a?(Fixnum)
    
    if new_value > @range.max
      @range.max
    elsif new_value < @range.min
      @range.min
    else
      new_value
    end
  end
  
  def self.new_standard_deviation_from(fitness)
    deviation_range = STANDARD_DEVIATION[:range].max - STANDARD_DEVIATION[:range].min
    STANDARD_DEVIATION[:range].max - deviation_range * fitness
  end
end