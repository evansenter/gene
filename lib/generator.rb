class Generator < Dsl
  include Aligner
  
  DEFAULT_XOVER_FREQ    = 0.1
  DEFAULT_MUTATION_FREQ = 0.25
  
  attr_accessor :current_sequence
  attr_reader   :cells, :gene_map, :fitness_map, :xover_freq, :mutation_freq, :num_genes, :num_points, :image_dimensions
  
  def initialize(cell_1, cell_2)
    @cells = (@cell_1, @cell_2 = cell_1, cell_2)
    validate_generator
    
    @gene_map         = align_cells
    @fitness_map      = cells.map(&:fitness)
    @current_sequence = rand(2)
    super
  end
  
  def combine
    Cell.new(num_genes, num_points, image_dimensions, &configuration)
  end
  
  private
  
  def finish_init
    @xover_freq    ||= DEFAULT_XOVER_FREQ
    @mutation_freq ||= DEFAULT_MUTATION_FREQ
  end
  
  def validate_generator
    # Once these parameters get pushed into a more global scope, this validation can go away completely, as can get_parameters.
    if @cell_1.get_parameters != @cell_2.get_parameters
      raise(ArgumentError, "The two cells don't have matching parameters")
    elsif !cells.all?(&:fitness)
      raise(ArgumentError, "Both cells need to have a fitness value")
    end
    
    @num_genes, @num_points, @image_dimensions = @cell_1.get_parameters
  end
  
  def align_cells
    alignment_for = align_crossover

    [
      @cell_1.genes_from_alignment_map(alignment_for[:cell_1]),
      @cell_2.genes_from_alignment_map(alignment_for[:cell_2])
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
          send(:"point_#{index}_#{axis}", &new_trait_from(model_gene.polygon.points[index].send(axis)))
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
    else super
    end
  end
end