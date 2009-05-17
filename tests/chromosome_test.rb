%w[test/unit rubygems mocha ../objects/chromosome.rb].each { |helper| require helper }

class ChromosomeTest < Test::Unit::TestCase
  def test_true
    assert true
  end

  def test_initialize
    image_dimensions = Point.new(640, 480)
    num_genes, num_points = 100, 10
    chromosome = Chromosome.new(num_genes, num_points, image_dimensions)
    assert_equal num_genes, chromosome.num_genes

    chromosome.genes.each do |gene|      
      assert_equal num_points, gene.polygon.num_points
      
      gene.polygon.points.each do |point|
        assert((0...image_dimensions.x) === point.x.value)
        assert((0...image_dimensions.y) === point.y.value)
      end
      
      gene.color.rgb.each do |vector|
        assert((0...256) === vector.value)
      end
      
      assert(Range.new(0.0, 1.0) === gene.color.a.value)
    end
  end
  
  def test_initialize__no_options_should_pass_through_an_empty_hash_to_gene_initialize
    image_dimensions = Point.new(640, 480)
    num_genes, num_points = 100, 10
    Gene.expects(:new).times(num_genes).with(num_points, image_dimensions, {})
    
    Chromosome.new(num_genes, num_points, image_dimensions)
  end
  
  def test_get_parameters
    image_dimensions = Point.new(640, 480)
    chromosome = Chromosome.new(100, 10, image_dimensions)
    
    assert_equal [100, 10, image_dimensions], chromosome.get_parameters
  end
  
  def test_genes_from_alignment_map
    image_dimensions = Point.new(640, 480)
    chromosome = Chromosome.new(3, 3, image_dimensions)

    assert_equal [chromosome.genes[2], chromosome.genes[0], chromosome.genes[1]], chromosome.genes_from_alignment_map([2, 0, 1])
  end
  
  def test_genes_by_alpha
    image_dimensions = Point.new(640, 480)
    
    gene_options = returning({}) do |hash|
      hash[:gene_0] = options_for_gene(:trait_a => { :default => 0.5 })
      hash[:gene_1] = options_for_gene(:trait_a => { :default => 0.0 })
      hash[:gene_2] = options_for_gene(:trait_a => { :default => 1.0 })
    end

    chromosome = Chromosome.new(3, 3, image_dimensions, gene_options)
    
    assert_equal [0.5, 0.0, 1.0], chromosome.genes.map(&:color).map(&:a).map(&:value)    
    assert_equal [1.0, 0.5, 0.0], chromosome.genes_by_alpha.map(&:color).map(&:a).map(&:value)
  end
  
  def test_meiosis
    num_genes  = 100
    num_points = 10
    image_dimensions = Point.new(640, 480)
    chromosome_1 = Chromosome.new(num_genes, num_points, image_dimensions)
    chromosome_2 = Chromosome.new(num_genes, num_points, image_dimensions)
    
    chromosome_1.expects(:get_parameters).twice.returns(:params, [num_genes, num_points, image_dimensions])
    chromosome_2.expects(:get_parameters).returns(:params)
    
    aligned_crossover = { :chromosome_1 => :aligned_chromosome_1, :chromosome_2 => :aligned_chromosome_2 }
    Geometry.expects(:align_crossover_for).with(chromosome_1, chromosome_2).returns(aligned_crossover)
    
    chromosome_1.expects(:genes_from_alignment_map).with(:aligned_chromosome_1).returns(chromosome_1.genes)
    chromosome_2.expects(:genes_from_alignment_map).with(:aligned_chromosome_2).returns(chromosome_2.genes)
    
    chromosome_1.expects(:fitness).twice.returns(:value)
    chromosome_2.expects(:fitness).twice.returns(:value)
    
    Chromosome.expects(:read_from).times(num_genes).returns(0)
    Chromosome.expects(:generate_gene_from).times(num_genes).returns({})
    
    new_chromosome = Chromosome.meiosis(chromosome_1, chromosome_2)
    assert_equal Chromosome, new_chromosome.class
  end
  
  def test_meiosis__chromosomes_dont_match
    num_genes  = 100
    num_points = 10
    image_dimensions = Point.new(640, 480)
    chromosome_1 = Chromosome.new(num_genes, num_points, image_dimensions)
    chromosome_2 = Chromosome.new(num_genes, num_points, image_dimensions)
    
    chromosome_1.expects(:get_parameters).returns(:chromsome_1)
    chromosome_2.expects(:get_parameters).returns(:chromsome_2)
    
    chromosome_1.expects(:fitness).never
    chromosome_2.expects(:fitness).never
    
    assert_raise ArgumentError do
      Chromosome.meiosis(chromosome_1, chromosome_2)
    end
  end
    
  def test_meiosis__missing_fitness_value
    num_genes  = 100
    num_points = 10
    image_dimensions = Point.new(640, 480)
    chromosome_1 = Chromosome.new(num_genes, num_points, image_dimensions)
    chromosome_2 = Chromosome.new(num_genes, num_points, image_dimensions)
    
    chromosome_1.expects(:get_parameters).returns(:params)
    chromosome_2.expects(:get_parameters).returns(:params)
    
    chromosome_1.expects(:fitness).returns(:value)
    chromosome_2.expects(:fitness).returns(nil)
    
    assert_raise ArgumentError do
      Chromosome.meiosis(chromosome_1, chromosome_2)
    end
  end
  
  def test_generate_gene_from
    Chromosome.stubs(:rand).returns(stub(:< => false)) # Ensures self.mutate(trait) returns the original trait.

    Trait.stubs(:new_standard_deviation_from).with(:fitness).returns(:value)
    Trait.any_instance.stubs(:setup_standard_deviation_with).returns(:standard_deviation)
    
    options = {
      :trait_x_0 => { :standard_deviation => :value, :default => 1 },
      :trait_y_0 => { :standard_deviation => :value, :default => 1 },

      :trait_x_1 => { :standard_deviation => :value, :default => 100 },
      :trait_y_1 => { :standard_deviation => :value, :default => 100 },

      :trait_x_2 => { :standard_deviation => :value, :default => 200 },
      :trait_y_2 => { :standard_deviation => :value, :default => 200 },

      :trait_r   => { :standard_deviation => :value, :default => 50 },
      :trait_g   => { :standard_deviation => :value, :default => 150 }, 
      :trait_b   => { :standard_deviation => :value, :default => 250 },
      :trait_a   => { :standard_deviation => :value, :default => 0.5 }
    }
    
    gene = Gene.new(3, Point.new(640, 480), options)
    assert_equal options, Chromosome.generate_gene_from(gene, :fitness)
  end
  
  def test_settings_hash_for
    Trait.expects(:new_standard_deviation_from).with(:fitness).returns(:new_standard_deviation)
    
    Chromosome.expects(:mutate).with(:trait, :mutation_freq).returns(:value)
    
    expected_hash = { :default => :value, :standard_deviation => :new_standard_deviation }
    assert_equal expected_hash, Chromosome.settings_hash_for(:trait, :fitness, :mutation_freq)
  end
        
  def test_settings_hash_for__default_mutation_freq
    Trait.expects(:new_standard_deviation_from).with(:fitness).returns(:new_standard_deviation)
    
    Chromosome.expects(:mutate).with(:trait, Chromosome::DEFAULT_MUTATION_FREQ).returns(:value)
    
    expected_hash = { :default => :value, :standard_deviation => :new_standard_deviation }
    assert_equal expected_hash, Chromosome.settings_hash_for(:trait, :fitness)
  end

  def test_mutate__returns_normal_trait_value
    trait = Trait.new(:x, (0..255), :default => 100)
    
    random_value = mock
    random_value.expects(:<).with(:mutation_freq).returns(false)
    Chromosome.expects(:rand).with(0).returns(random_value)
    
    assert_equal 100, Chromosome.mutate(trait, :mutation_freq)
  end
      
  def test_mutate__returns_mutated_trait_value__default_mutation_freq
    trait = Trait.new(:x, (0..255), :default => 100)
    trait.expects(:mutated_value).returns(:random_value)
    
    random_value = mock
    random_value.expects(:<).with(Chromosome::DEFAULT_MUTATION_FREQ).returns(true)
    Chromosome.expects(:rand).with(0).returns(random_value)
    
    assert_equal :random_value, Chromosome.mutate(trait)
  end

  def test_read_from__returns_current_sequence    
    random_value = mock
    random_value.expects(:<).with(:xover_freq).returns(false)
    Chromosome.expects(:rand).with(0).returns(random_value)
    
    assert_equal :current_sequence, Chromosome.read_from(:current_sequence, :xover_freq)
  end    
      
  def test_read_from__returns_alternate_sequence__default_xover_freq 
    random_value = mock
    random_value.expects(:<).with(Chromosome::DEFAULT_XOVER_FREQ).returns(true)
    Chromosome.expects(:rand).with(0).returns(random_value)
    Chromosome.expects(:flip).with(:current_sequence).returns(:alternate_sequence)
    
    assert_equal :alternate_sequence, Chromosome.read_from(:current_sequence)
  end

  def test_flip
    assert_equal 0, Chromosome.flip(1)
    assert_equal 1, Chromosome.flip(0)
  end
  
  private
  
  def options_for_gene(options = {})
    options = {
      :trait_x_0 => { :default => 1 },
      :trait_y_0 => { :default => 1 },
                      
      :trait_x_1 => { :default => 100 },
      :trait_y_1 => { :default => 100 },
                      
      :trait_x_2 => { :default => 200 },
      :trait_y_2 => { :default => 200 },
                      
      :trait_r   => { :default => 50 },
      :trait_g   => { :default => 150 }, 
      :trait_b   => { :default => 250 },
      :trait_a   => { :default => 0.5 }
    }.merge(options)
  end
  
  protected
  
  def mutation_distribution_helper
    trait = Trait.new(:x, (0..255), { :default => 10, :standard_deviation => 0.25 })
    distribution = trait.range.map { 0 }
    
    1000.times do
      value = Chromosome.mutate(trait, 0.25)
      distribution[value] += 1
    end
    
    sum = distribution.inject(0.0) { |sum, value| sum + value }
    p distribution.map { |value| value / sum * 100 }
  end
end