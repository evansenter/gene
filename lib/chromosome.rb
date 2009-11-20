class Chromosome
  include Geometry
  
  attr_accessor :fitness
  attr_reader   :num_genes, :num_points, :image_dimensions, :genes
  
  DEFAULT_FITNESS = 0.5
  
  def initialize(num_genes, num_points, image_dimensions, options = {})        
    @num_genes        = num_genes
    @num_points       = num_points
    @image_dimensions = image_dimensions
    @fitness          = options[:fitness] || DEFAULT_FITNESS
    @genes            = num_genes.times.map { |index| Gene.new(num_points, image_dimensions, options[:"gene_#{index}"] || {}) }
  end
  
  def get_parameters
    [num_genes, num_points, image_dimensions]
  end
  
  def genes_by_alpha
    genes.sort { |gene_1, gene_2| gene_2.color.a.value <=> gene_1.color.a.value }
  end
  
  def genes_from_alignment_map(alignment)
    alignment.map { |index| genes[index] }
  end
end