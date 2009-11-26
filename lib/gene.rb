class Gene < Dsl
  attr_reader :polygon, :color
  
  private
  
  def finish_init
    fill_out_polygon
    fill_out_color
    initialize_singleton_methods_for_polygon_and_color
  end
  
  def fill_out_polygon
    @polygon ||= []
    @polygon   = num_points.times.map do |index|
      if polygon[index]
        returning(polygon[index]) do |point|
          point.x ||= Trait.new(:x, 0...image_dimensions.x)
          point.y ||= Trait.new(:y, 0...image_dimensions.y)
        end
      else
        Point.new(
          Trait.new(:x, 0...image_dimensions.x),
          Trait.new(:y, 0...image_dimensions.y)
        )
      end
    end
  end
  
  def fill_out_color
    @color  ||= Color.new
    color.r ||= Trait.new(:value, 0..255)
    color.g ||= Trait.new(:value, 0..255)
    color.b ||= Trait.new(:value, 0..255)
    color.a ||= Trait.new(:value, 0.0..1.0)
  end
  
  def initialize_singleton_methods_for_polygon_and_color
    :points[polygon]     = lambda { self }
    :num_points[polygon] = lambda { size }
    
    :rgb[color] = lambda { [r, g, b] }
  end
  
  def point_at(index, *args, &block)
    point = (@polygon ||= [])[index] ||= Point.new
    x, y  = args
    
    point.x = Trait.new(:x, 0...image_dimensions.x) { set_value x }
    point.y = Trait.new(:x, 0...image_dimensions.y) { set_value y }
  end
  
  def point_from(index, name, &block)
    point = (@polygon ||= [])[index] ||= Point.new
    
    point.send(:"#{name}=", Trait.new(:"#{name}", 0...image_dimensions.send(:"#{name}"), &block))
  end
  
  def color_from(name, &block)
    @color ||= Color.new
    
    if %w[r g b].include?(name)
      color.send(:"#{name}=", Trait.new(:"#{name}", 0..255, &block))
    elsif %w[a].include?(name)
      color.send(:"#{name}=", Trait.new(:"#{name}", 0.0..1.0, &block))
    end
  end
  
  def method_missing(name, *args, &block)
    case name.to_s
    when /^point_(\d+)$/:      point_at($1.to_i, *args, &block)
    when /^point_(\d+)_(\w)$/: point_from($1.to_i, $2, &block)
    when /^trait_(\w)$/:       color_from($1, &block)
    else super
    end
  end
end