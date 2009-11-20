class Generator
  include Aligner
  
  attr_accessor :current_sequence
  attr_reader   :chromosomes, :gene_map, :fitness_map, :xover_freq, :mutation_freq, :num_genes, :num_points, :image_dimensions
  
  DEFAULT_XOVER_FREQ    = 0.1
  DEFAULT_MUTATION_FREQ = 0.25
  
  def initialize(chromosome_1, chromosome_2, options = {})    
    @chromosomes = (@chromosome_1, @chromosome_2 = chromosome_1, chromosome_2)
    validate_generator
    
    @gene_map         = align_chromosomes
    @fitness_map      = chromosomes.map(&:fitness)
    @current_sequence = rand(2)
    @xover_freq       = options[:xover_freq]    || DEFAULT_XOVER_FREQ
    @mutation_freq    = options[:mutation_freq] || DEFAULT_MUTATION_FREQ
  end
  
  def combine
    Chromosome.new(num_genes, num_points, image_dimensions, generate_chromosome_settings)
  end
  
  private
  
  def validate_generator
    if @chromosome_1.get_parameters != @chromosome_2.get_parameters
      raise(ArgumentError, "The two chromosomes don't have matching parameters")
    elsif !chromosomes.all?(&:fitness)
      raise(ArgumentError, "Both chromosomes need to have a fitness value")
    end
    
    @num_genes, @num_points, @image_dimensions = @chromosome_1.get_parameters
  end
  
  def align_chromosomes
    alignment_for = align_crossover

    [
      @chromosome_1.genes_from_alignment_map(alignment_for[:chromosome_1]),
      @chromosome_2.genes_from_alignment_map(alignment_for[:chromosome_2])
    ]
  end
  
  def generate_chromosome_settings
    returning({}) do |chromosome_settings|
      num_genes.times.each do |index|
        chromosome_settings[:"gene_#{index}"] = generate_gene_at(index)
      end
    end
  end
  
  def generate_gene_at(index)  
    gene = gene_map[read_sequence][index]

    returning({}) do |gene_settings|      
      num_points.times.each do |index|
        [:x, :y].each do |axis| 
          gene_settings[:"trait_#{axis}_#{index}"] = settings_hash_for(gene.polygon.points[index].send(axis))
        end
      end

      gene.color.each_pair do |color, trait|
        gene_settings[:"trait_#{color}"] = settings_hash_for(trait)
      end
    end
  end
  
  def settings_hash_for(trait)
    {
      :default            => mutate(trait),
      :standard_deviation => Trait.new_standard_deviation_from(fitness_map[current_sequence])
    }
  end
  
  def mutate(trait)
    rand(0) < mutation_freq ? trait.mutated_value : trait.value
  end
  
  def read_sequence
    rand(0) < xover_freq ? self.current_sequence ^= 1 : current_sequence
  end
end