class Trait
  include Calculator
  
  STANDARD_DEVIATION = {
    :default => 0.1,
    :range   => 0.01..0.25
  }
  
  attr_reader :value, :range, :standard_deviation
  
  def initialize(name, range, options = {})
    @range = range
    setup_standard_deviation_with(options[:standard_deviation])
    setup_value_with(name, options[:default])
  end
  
  def setup_standard_deviation_with(deviation)
    @standard_deviation = (deviation || STANDARD_DEVIATION[:default]) * range.max
  end
  
  def setup_value_with(name, default)
    if default && !range.include?(default)
      raise(ArgumentError, "Can't generate a trait with value (#{@value}) outside the range (#{range})")
    end
      
    @value = default || Trait.generate_value(range.max)
    name[self] = lambda { @value }
  end
  
  def mutated_value
    new_value = value + standard_deviation * Trait.get_normal_random_variable
    new_value = new_value.round if value.is_a?(Fixnum)
    
    if new_value > range.max
      range.max
    elsif new_value < range.min
      range.min
    else
      new_value
    end
  end
  
  def self.new_standard_deviation_from(fitness)
    # Tighten the deviation from max to min linearly as the fitness increases.
    deviation_range = STANDARD_DEVIATION[:range].max - STANDARD_DEVIATION[:range].min
    STANDARD_DEVIATION[:range].max - deviation_range * fitness
  end
end