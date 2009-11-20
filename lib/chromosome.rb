class Chromosome
  include Meiosis
  
  attr_accessor :fitness
  attr_reader   :image_dimensions, :genes
  
  DEFAULT_FITNESS       = 0.5
  DEFAULT_XOVER_FREQ    = 0.1
  DEFAULT_MUTATION_FREQ = 0.25
  
  :default_xover_freq[self]    = lambda { DEFAULT_XOVER_FREQ }
  :default_mutation_freq[self] = lambda { DEFAULT_MUTATION_FREQ }
  
  def initialize(num_genes, num_points, image_dimensions, options = {})        
    @num_points       = num_points
    @image_dimensions = image_dimensions
    @fitness          = options[:fitness] || DEFAULT_FITNESS
    
    options.default = {}
    @genes = (0...num_genes).map { |index| Gene.new(@num_points, @image_dimensions, options[:"gene_#{index}"]) }
    
    :num_genes[self] = lambda { @genes.size }
  end
  
  def get_parameters
    [num_genes, @num_points, @image_dimensions]
  end
  
  def genes_by_alpha
    @genes.sort { |gene_1, gene_2| gene_2.color.a.value <=> gene_1.color.a.value }
  end
end