class Cell < Dsl
  include Geometry
  
  DEFAULT_FITNESS = 0.5
  
  attr_accessor :fitness
  attr_reader   :genes
  
  def genes_by_alpha
    genes.sort { |gene_1, gene_2| gene_2.color.a.value <=> gene_1.color.a.value }
  end
  
  def genes_from_alignment_map(alignment)
    alignment.map { |index| genes[index] }
  end
  
  private
  
  def finish_init
    @fitness ||= DEFAULT_FITNESS
    fill_out_genes
  end
  
  def fill_out_genes
    @genes = num_genes.times.map { |index| (@genes ||= [])[index] || Gene.new }
  end
  
  def method_missing(name, *args, &block)
    case name.to_s
    when /^gene_(\d+)$/: (@genes ||= [])[$1.to_i] = Gene.new(&block)
    when "set_fitness":   @fitness = args.first
    else super
    end
  end
end