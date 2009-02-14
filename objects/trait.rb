%w[calculator].each do |file|
  require File.join("#{File.dirname(__FILE__)}", "#{file}.rb")
end

class Trait
  include Calculator
  
  DEFAULT_STANDARD_DEVIATION = 0.1
  
  attr_reader :value, :range, :standard_deviation
  
  def initialize(name, range, options = {})
    @range              = setup_range_with(range)
    @standard_deviation = setup_standard_deviation_with(options[:standard_deviation])
    @value              = setup_value_with(options[:default])
    
    eval "def self.#{name}; @value; end"
  end

  def setup_range_with(range)
    returning(range) do |object|
      def object.max
        self.end.is_a?(Float) ? self.end : super
      end
    
      def object.min
        self.begin.is_a?(Float) ? self.begin : super
      end
    end
  end
  
  def setup_standard_deviation_with(standard_deviation)
    (standard_deviation || DEFAULT_STANDARD_DEVIATION) * @range.max
  end
  
  def setup_value_with(value)
    if value && !(range.include?(value))
      raise(ArgumentError, "Can't generate a trait with a default value (#{value}) outside the allowed range (#{@range})")
    else
      value || Calculator.generate_value(@range.max)
    end
  end
  
  def mutated_value
    new_value = @value + (@standard_deviation * Calculator.get_uniform_random_variable)
    new_value = new_value.round if @value.is_a?(Fixnum)
    
    if new_value > @range.max
      @range.max
    elsif new_value < @range.min
      @range.min
    else
      new_value
    end
  end
end