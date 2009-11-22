class Trait
  include Calculator
  
  STANDARD_DEVIATION = {
    :default => 0.1,
    :range   => 0.01..0.25
  }
  
  attr_reader :name, :value, :range, :standard_deviation
  
  def initialize(name, range, &block)
    @name  = name
    @range = range

    if block_given?
      @original_self = block.binding.eval("self")
      instance_eval(&block)
    end
  ensure
    fill_out_value
    fill_out_deviation
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
  
  private
  
  def fill_out_value    
    @value   ||= Trait.generate_value(range.max)
    name[self] = lambda { @value }
  end
  
  def fill_out_deviation
    @standard_deviation ||= STANDARD_DEVIATION[:default] * range.max
  end
  
  def new_standard_deviation_from(fitness)
    deviation_range = STANDARD_DEVIATION[:range].max - STANDARD_DEVIATION[:range].min
    STANDARD_DEVIATION[:range].max - deviation_range * fitness
  end
  
  def method_missing(name, *args, &block) 
    method_name = name.to_s
    
    if method_name.match(/^set_value$/) && range.include?(args.first)
      @value = args.first      
    elsif method_name.match(/^deviation$/)
      @standard_deviation = args.first * range.max
    elsif method_name.match(/^deviate_from$/) && STANDARD_DEVIATION[:range].include?(args.first)
      @standard_deviation = new_standard_deviation_from(args.first)
    elsif @original_self
      @original_self.send(name, *args, &block)
    else
      super
    end
  end
end