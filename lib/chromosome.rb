class Chromosome
  include Geometry
  
  DEFAULT_FITNESS = 0.5
  
  attr_accessor :fitness
  attr_reader   :num_genes, :num_points, :image_dimensions, :genes
  
  def initialize(num_genes, num_points, image_dimensions, &block)        
    @num_genes        = num_genes
    @num_points       = num_points
    @image_dimensions = image_dimensions
    
    if block_given?
      @original_self = block.binding.eval("self")
      instance_eval(&block)
    end
  ensure
    @fitness ||= DEFAULT_FITNESS
    fill_out_genes
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
  
  private
  
  def fill_out_genes
    @genes = num_genes.times.map { |index| (@genes ||= [])[index] || Gene.new(num_points, image_dimensions) }
  end
  
  def method_missing(name, *args, &block)
    method_name = name.to_s
    
    if method_name.match(/^gene_(\d+)$/) && (0...num_genes).include?($1.to_i) && block_given?
      (@genes ||= [])[$1.to_i] = Gene.new(num_points, image_dimensions, &block)
    elsif method_name.match(/^set_fitness$/) && (0..1).include?(args.first)
      @fitness = args.first
    elsif @original_self
      @original_self.send(name, *args, &block)
    else
      super
    end
  end
end