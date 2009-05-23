%w[gene meiosis].each do |file|
  require File.join("#{File.dirname(__FILE__)}", "#{file}.rb")
end

class Chromosome
  include Meiosis
  
  attr_accessor :fitness
  attr_reader   :image_dimensions, :genes
  
  DEFAULT_XOVER_FREQ    = 0.1
  DEFAULT_MUTATION_FREQ = 0.25
  
  :default_xover_freq[self]    = lambda { DEFAULT_XOVER_FREQ }
  :default_mutation_freq[self] = lambda { DEFAULT_MUTATION_FREQ }
  
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
  
  def genes_by_alpha
    @genes.sort { |gene_1, gene_2| gene_2.color.a.value <=> gene_1.color.a.value }
  end
end