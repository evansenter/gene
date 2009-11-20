class Petri
  attr_reader :dish
  
  def initialize(num_organisms, num_genes, num_points, image_dimensions)
    @dish = (0...num_organisms).map do
      Chromosome.new(num_genes, num_points, image_dimensions)
    end
  end
  
  def sort_by_fitness
    @dish.sort! { |a, b| a.fitness <=> b.fitness }
  end
  
  def update_fitness
    
  end
end