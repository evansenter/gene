require File.join("#{File.dirname(__FILE__)}", "gene.rb")

class Chromosome
  include Geometry
  
  attr_accessor :fitness
  attr_reader   :image_dimensions, :genes
  
  def initialize(num_genes, num_points, image_dimensions, options = {})
    options.default = {}
        
    @num_points       = num_points
    @image_dimensions = image_dimensions
    @genes = (0...num_genes).map { |index| Gene.new(@num_points, @image_dimensions, options[:"gene_#{index}"]) }
    
    :num_genes[self] = lambda { @genes.size }
  end
  
  def get_parameters
    [num_genes, @num_points, @image_dimensions]
  end
  
  def genes_from_alignment_map(alignment)
    alignment.map { |index| @genes[index] }
  end
  
  def genes_by_alpha
    @genes.sort { |gene_1, gene_2| gene_2.color.a.value <=> gene_1.color.a.value }
  end
end