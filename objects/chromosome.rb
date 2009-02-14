%w[gene].each do |file|
  require File.join("#{File.dirname(__FILE__)}", "#{file}.rb")
end

class Chromosome
  attr_accessor :fitness
  attr_reader   :image_dimensions, :genes
  
  def initialize(num_genes, num_points, image_dimensions, options = {})
    options.default = {}
        
    @image_dimensions = image_dimensions
    @genes = (0...num_genes).map do |index|
      Gene.new(num_points, @image_dimensions, options[:"gene_#{index}"])
    end
  end
  
  def num_genes; @genes.size; end
  
  def get_parameters
    sample_gene = @genes.first
    [num_genes, sample_gene.polygon.num_points, @image_dimensions]
  end
end