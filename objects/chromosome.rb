require File.join("#{File.dirname(__FILE__)}", "gene.rb")

class Chromosome
  attr_accessor :fitness
  attr_reader   :image_dimensions, :genes
  
  def initialize(num_genes, num_points, image_dimensions, options = {})
    options.default = {}
        
    @num_points       = num_points
    @image_dimensions = image_dimensions
    @genes = (0...num_genes).map { |index| Gene.new(@num_points, @image_dimensions, options[:"gene_#{index}"]) }
  end
  
  def num_genes; @genes.size; end
  
  def get_parameters
    [num_genes, @num_points, @image_dimensions]
  end
end