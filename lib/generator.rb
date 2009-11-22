class Generator
  include Dsl, Aligner
  
  DEFAULT_XOVER_FREQ    = 0.1
  DEFAULT_MUTATION_FREQ = 0.25
  
  attr_accessor :current_sequence
  attr_reader   :chromosomes, :gene_map, :fitness_map, :xover_freq, :mutation_freq, :num_genes, :num_points, :image_dimensions
  
  def initialize(chromosome_1, chromosome_2)
    @chromosomes = (@chromosome_1, @chromosome_2 = chromosome_1, chromosome_2)
    validate_generator
    
    @gene_map         = align_chromosomes
    @fitness_map      = chromosomes.map(&:fitness)
    @current_sequence = rand(2)
  end
  
  def combine
    Chromosome.new(num_genes, num_points, image_dimensions, &configuration)
  end
  
  private
  
  def finish_init
    @xover_freq    ||= DEFAULT_XOVER_FREQ
    @mutation_freq ||= DEFAULT_MUTATION_FREQ
  end
  
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
  
  def configuration
    lambda do
      num_genes.times.each do |index|
        send(:"gene_#{index}", &new_gene_from(gene_map[read_sequence][index]))
      end
    end
  end
  
  def new_gene_from(model_gene)
    lambda do
      num_points.times.each do |index|
        [:x, :y].each do |axis| 
          send(:"trait_#{axis}_#{index}", &new_trait_from(model_gene.polygon.points[index].send(axis)))
        end
      end

      model_gene.color.each_pair do |color, model_trait|
        send(:"trait_#{color}", &new_trait_from(model_trait))
      end
    end
  end
  
  def new_trait_from(model_trait)
    lambda do
      set_value mutate(model_trait)
      deviate_from fitness_map[current_sequence]
    end
  end
  
  def mutate(trait)
    rand(0) < mutation_freq ? trait.mutated_value : trait.value
  end
  
  def read_sequence
    rand(0) < xover_freq ? self.current_sequence ^= 1 : current_sequence
  end
  
  def method_missing(name, *args, &block)
    case name.to_s
    when "set_xover_freq":    @xover_freq    = args.first
    when "set_mutation_freq": @mutation_freq = args.first
    else :_super
    end
  end
end