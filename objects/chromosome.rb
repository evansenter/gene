require File.join("#{File.dirname(__FILE__)}", "gene.rb")

class Chromosome
  include Geometry
  
  attr_accessor :fitness
  attr_reader   :image_dimensions, :genes
  
  DEFAULT_XOVER_FREQ    = 0.1
  DEFAULT_MUTATION_FREQ = 0.25
  
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
  
  def self.meiosis(chromosome_1, chromosome_2, options = {})
    chromosomes = [chromosome_1, chromosome_2]
    
    if chromosomes.first.get_parameters != chromosomes.last.get_parameters
      raise(ArgumentError, "The two chromosomes don't have matching parameters")
    elsif !chromosomes.all?(&:fitness)
      raise(ArgumentError, "Both chromosomes need to have a fitness value")
    end
    
    aligned_chromosomes = Geometry.align_crossover_for(chromosome_1, chromosome_2)
    genes_for = [
                  chromosome_1.genes_from_alignment_map(aligned_chromosomes[:chromosome_1]),
                  chromosome_2.genes_from_alignment_map(aligned_chromosomes[:chromosome_2])
                ]
                
    fitness_for      = chromosomes.map(&:fitness)
    current_sequence = rand(2)
    xover_freq       = options[:xover_freq]    || DEFAULT_XOVER_FREQ
    mutation_freq    = options[:mutation_freq] || DEFAULT_MUTATION_FREQ
    
    num_genes, num_points, image_dimensions = chromosomes.first.get_parameters
    
    chromosome_settings = returning({}) do |new_chromosome_settings|
      (0...num_genes).each do |index|
        current_sequence = read_from(current_sequence, xover_freq)
        new_chromosome_settings[:"gene_#{index}"] = generate_gene_from(genes_for[current_sequence][index], fitness_for[current_sequence], mutation_freq)
      end
    end
    
    Chromosome.new(num_genes, num_points, image_dimensions, chromosome_settings)
  end
  
  private
  
  def self.generate_gene_from(gene, fitness, mutation_freq = DEFAULT_MUTATION_FREQ)
    points = gene.polygon.points
    
    returning({}) do |gene_settings|      
      (0...gene.polygon.num_points).each do |index|
        [:x, :y].each { |axis| gene_settings[:"trait_#{axis}_#{index}"] = settings_hash_for(points[index].send(axis), fitness, mutation_freq) }
      end

      gene.color.to_hash.each do |color, trait|
        gene_settings[:"trait_#{color}"] = settings_hash_for(trait, fitness, mutation_freq)
      end
    end
  end
  
  def self.settings_hash_for(trait, fitness, mutation_freq = DEFAULT_MUTATION_FREQ)
    {
      :default            => mutate(trait, mutation_freq),
      :standard_deviation => Trait.new_standard_deviation_from(fitness)
    }
  end
  
  def self.mutate(trait, mutation_freq = DEFAULT_MUTATION_FREQ)
    rand(0) < mutation_freq ? trait.mutated_value : trait.value
  end
  
  def self.read_from(current_sequence, xover_freq = DEFAULT_XOVER_FREQ)
    rand(0) < xover_freq ? flip(current_sequence) : current_sequence
  end
  
  def self.flip(current_sequence)
    current_sequence ^ 1
  end
end