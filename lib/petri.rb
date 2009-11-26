class Petri < Dsl
  attr_reader :original_image, :dish
  
  def initialize(image)
    @original_image = image
    prepare_image
    super
  end
  
  private
  
  def prepare_image
    set_parameter(:image_dimensions, Point.new(640, 480))
  end
  
  def finish_init
    set_parameter(:num_cells, 30) unless self.class.respond_to?(:num_cells)
    set_parameter(:num_genes, 50) unless self.class.respond_to?(:num_genes)
    set_parameter(:num_points, 3) unless self.class.respond_to?(:num_points)
    
    fill_out_cells
  end
  
  def fill_out_cells
    @dish = num_cells.times.map { Cell.new }
  end
  
  def set_parameter(name, value)
    name = name.to_s.gsub(/^set_/, "")
    
    class_metaclass.instance_eval do
      attr_reader name
    end
    
    self.class.instance_variable_set(:"@#{name}", value)
  end
  
  def method_missing(name, *args, &block) 
    case name
    when :set_num_cells, :set_num_genes, :set_num_points: set_parameter(name, args.first)
    else super
    end
  end
end