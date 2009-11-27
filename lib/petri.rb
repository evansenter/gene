class Petri < Dsl
  attr_reader :round, :image, :dish
  
  def initialize(image_path)
    @round = 0
    prepare_image_at(image_path)
    super
  end
  
  private
  
  def prepare_image_at(image_path)
    @image = Magick::Image.read(image_path).first
    set_parameter(:image_dimensions, Point.new(image.columns, image.rows))
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
  
  def next_round
    @round += 1
  end
  
  def set_num_cells(desired)
    set_parameter(:num_cells, (desired % 3) == 0 ? desired : desired + 3 - (desired % 3))
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
    when :set_num_genes, :set_num_points: set_parameter(name, args.first)
    else super
    end
  end
end