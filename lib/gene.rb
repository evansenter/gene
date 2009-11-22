class Gene
  attr_reader :polygon, :num_points, :image_dimensions, :color
  
  def initialize(num_points, image_dimensions, &block)
    @num_points       = num_points
    @image_dimensions = image_dimensions
    
    assert_at_least 3, num_points

    if block_given?
      @original_self = block.binding.eval("self")
      instance_eval(&block)
    end
  ensure
    fill_out_polygon
    fill_out_color
    initialize_singleton_methods_for_polygon_and_color
  end
  
  private
  
  def fill_out_polygon
    @polygon ||= []
    @polygon   = num_points.times.map do |index|
      if polygon[index]
        returning(polygon[index]) do |point|
          point.x ||= Trait.new(:x, (0...image_dimensions.x))
          point.y ||= Trait.new(:y, (0...image_dimensions.y))
        end
      else
        Point.new(
          Trait.new(:x, (0...image_dimensions.x)),
          Trait.new(:y, (0...image_dimensions.y))
        )
      end
    end
  end
  
  def fill_out_color
    @color  ||= Color.new
    color.r ||= Trait.new(:value, (0..255))
    color.g ||= Trait.new(:value, (0..255))
    color.b ||= Trait.new(:value, (0..255))
    color.a ||= Trait.new(:value, (0.0..1.0))
  end
  
  def initialize_singleton_methods_for_polygon_and_color
    :points[polygon]     = lambda { self }
    :num_points[polygon] = lambda { size }
    
    :rgb[color] = lambda { [r, g, b] }
  end
  
  def method_missing(name, *args, &block)
    method_name = name.to_s
    
    if method_name =~ /^trait_(\w)_(\d+)$/ && %w[x y].include?($1) && (0...num_points).include?($2.to_i) && block_given?
      ((@polygon ||= [])[$2.to_i] ||= Point.new).send(:"#{$1}=", Trait.new(:"#{$1}", (0...image_dimensions.x), &block))
    elsif method_name =~ /^trait_(\w)$/ && %w[r g b].include?($1) && block_given?
      (@color ||= Color.new).send(:"#{$1}=", Trait.new(:"#{$1}", (0..255), &block))      
    elsif method_name =~ /^trait_(\w)$/ && %w[a].include?($1) && block_given?
      (@color ||= Color.new).send(:"#{$1}=", Trait.new(:"#{$1}", (0.0..1.0), &block))
    elsif @original_self
      @original_self.send(name, *args, &block)
    else
      super
    end
  end
end