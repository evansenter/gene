class Trait < Dsl
  include Calculator
  
  STANDARD_DEVIATION = {
    :default => 0.1,
    :range   => 0.01..0.25
  }
  
  attr_reader :value, :range, :standard_deviation
  
  def initialize(range)
    @range = range
    super
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
  
  def percentify
    "#{value / range.max.to_f * 100}%"
  end
  
  private
  
  def finish_init
    fill_out_value
    fill_out_deviation
  end
  
  def fill_out_value    
    @value ||= Trait.generate_value(range.max)
  end
  
  def fill_out_deviation
    @standard_deviation ||= STANDARD_DEVIATION[:default] * range.max
  end
  
  def new_standard_deviation_from(fitness)
    deviation_range = STANDARD_DEVIATION[:range].max - STANDARD_DEVIATION[:range].min
    STANDARD_DEVIATION[:range].max - deviation_range * fitness
  end
  
  def method_missing(name, *args, &block)
    case name.to_s
    when /^set_value$/:    @value              = args.first
    when /^deviation$/:    @standard_deviation = args.first * range.max
    when /^deviate_from$/: @standard_deviation = new_standard_deviation_from(args.first)
    else super end
  end
end