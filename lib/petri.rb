class Petri < Dsl
  include Imagine
  
  attr_reader :round, :target_image, :dish
  
  def initialize(image_path)
    @round = 0
    prepare_image_at(image_path)
    super
  end
  
  def evolve
    top_k = dish[0, dish.length / 3 * 2]
    @dish = (top_k + (dish.length - top_k.length).times.inject([]) do |new_cells, index|
      new_cells << Generator.new(top_k[rand(top_k.length)], top_k[rand(top_k.length)]).combine
    end)
    
    calculate_fitnesses
    sort_by_fitness!
    
    if (round % 100).zero?
      dish.first.image.write("#{round}.png")
      puts dish.first.genes.map { |gene| "[" + gene.polygon.map { |point| "#{point.x.value}, #{point.y.value}" }.join(", ") + "]" }.join(", ")
      puts "Fitness: #{dish.first.fitness}"
    end
    
    next_round
  end
  
  private
  
  def prepare_image_at(image_path)
    @target_image = Magick::Image.read(image_path).first
    set_parameter(:image_dimensions, Point.new(target_image.columns, target_image.rows))
  end
  
  def finish_init
    set_parameter(:num_cells,  6) unless self.class.respond_to?(:num_cells)
    set_parameter(:num_genes,  3) unless self.class.respond_to?(:num_genes)
    set_parameter(:num_points, 4) unless self.class.respond_to?(:num_points)
    
    fill_out_cells
    calculate_fitnesses
    sort_by_fitness!
  end
  
  def fill_out_cells
    @dish = num_cells.times.map { Cell.new }
  end
  
  def calculate_fitnesses
    dish.each do |cell|
      cell.fitness ||= compare_image_to(cell.image)
    end
  end
  
  def sort_by_fitness!
    dish.sort! { |a, b| b.fitness <=> a.fitness }
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