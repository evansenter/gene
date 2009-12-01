class Gene < Dsl
  include Geometry
  
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
          point.x ||= Trait.new(0...image_dimensions.x)
          point.y ||= Trait.new(0...image_dimensions.y)
        end
      else
        Point.new(
          Trait.new(0...image_dimensions.x),
          Trait.new(0...image_dimensions.y)
        )
      end
    end
  end
  
  def fill_out_color
    @color ||= Color.new
    color.each_pair { |channel, trait| color.send(:"#{channel}=", Trait.new(0.0..1.0)) unless trait }
  end
  
  def initialize_singleton_methods_for_polygon_and_color
    :points[polygon]     = lambda { self }
    :num_points[polygon] = lambda { size }
  end
  
  def point_at(index, x, y)
    point = (@polygon ||= [])[index] ||= Point.new
    
    point.x = Trait.new(0...image_dimensions.x) { set_value x }
    point.y = Trait.new(0...image_dimensions.y) { set_value y }
  end
  
  def point_from(index, name, &block)
    point = (@polygon ||= [])[index] ||= Point.new
    
    point.send(:"#{name}=", Trait.new(0...image_dimensions.send(:"#{name}"), &block))
  end
  
  def color_from(channel, &block)
    @color ||= Color.new
    color.send(:"#{channel}=", Trait.new(0.0..1.0, &block))
  end
  
  def method_missing(name, *args, &block)
    case name.to_s
    when /^point_(\d+)$/:      point_at($1.to_i, *args)
    when /^point_(\d+)_(\w)$/: point_from($1.to_i, $2, &block)
    when /^trait_(\w)$/:       color_from($1, &block)
    else super
    end
  end
end