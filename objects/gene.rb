%w[trait point color].each do |file|
  require File.join("#{File.dirname(__FILE__)}", "#{file}.rb")
end

class Gene
  attr_reader :polygon, :color
  
  def initialize(num_points, image_dimensions, options = {})
    options.default = {}
    
    unless num_points >= 3
      raise(ArgumentError, "You must provide at least 3 points per polygon (#{num_points} #{num_points == 1 ? 'was' : 'were'} requested)")
    end
    
    @polygon = (0...num_points).map do |index|
      Point.new(
        Trait.new(:x, (0...image_dimensions.x), options[:"trait_x_#{index}"]),
        Trait.new(:y, (0...image_dimensions.y), options[:"trait_y_#{index}"])
      )
    end

    :points[@polygon] = lambda { self }
    :num_points[@polygon] = lambda { size }
    
    @color = Color.new(
      Trait.new(:value, (0..255),   options[:trait_r]),
      Trait.new(:value, (0..255),   options[:trait_g]),
      Trait.new(:value, (0..255),   options[:trait_b]),
      Trait.new(:value, (0.0..1.0), options[:trait_a])
    )

    :rgb[@color] = lambda { [r, g, b] }
  end
end