%w[test/unit rubygems mocha ../lib/chromosome.rb].each { |helper| require helper }

class MeiosisTest < Test::Unit::TestCase
  def test_true
    assert true
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

  def test_validate_meiosis_for__chromosomes_dont_match
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
  
  def test_validate_meiosis_for__missing_fitness_value
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
  
  def test_genes_from_alignment_map
    image_dimensions = Point.new(640, 480)
    chromosome = Chromosome.new(3, 3, image_dimensions)

    assert_equal [chromosome.genes[2], chromosome.genes[0], chromosome.genes[1]], chromosome.send(:genes_from_alignment_map, [2, 0, 1])
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
    assert_equal options, Chromosome.send(:generate_gene_from, gene, :fitness)
  end

  def test_settings_hash_for
    Trait.expects(:new_standard_deviation_from).with(:fitness).returns(:new_standard_deviation)
  
    Chromosome.expects(:mutate).with(:trait, :mutation_freq).returns(:value)
  
    expected_hash = { :default => :value, :standard_deviation => :new_standard_deviation }
    assert_equal expected_hash, Chromosome.send(:settings_hash_for, :trait, :fitness, :mutation_freq)
  end
      
  def test_settings_hash_for__default_mutation_freq
    Trait.expects(:new_standard_deviation_from).with(:fitness).returns(:new_standard_deviation)
  
    Chromosome.expects(:mutate).with(:trait, Chromosome::DEFAULT_MUTATION_FREQ).returns(:value)
  
    expected_hash = { :default => :value, :standard_deviation => :new_standard_deviation }
    assert_equal expected_hash, Chromosome.send(:settings_hash_for, :trait, :fitness)
  end

  def test_mutate__returns_normal_trait_value
    trait = Trait.new(:x, (0..255), :default => 100)
  
    random_value = mock
    random_value.expects(:<).with(:mutation_freq).returns(false)
    Chromosome.expects(:rand).with(0).returns(random_value)
  
    assert_equal 100, Chromosome.send(:mutate, trait, :mutation_freq)
  end
    
  def test_mutate__returns_mutated_trait_value__default_mutation_freq
    trait = Trait.new(:x, (0..255), :default => 100)
    trait.expects(:mutated_value).returns(:random_value)
  
    random_value = mock
    random_value.expects(:<).with(Chromosome::DEFAULT_MUTATION_FREQ).returns(true)
    Chromosome.expects(:rand).with(0).returns(random_value)
  
    assert_equal :random_value, Chromosome.send(:mutate, trait)
  end

  def test_read_from__returns_current_sequence    
    random_value = mock
    random_value.expects(:<).with(:xover_freq).returns(false)
    Chromosome.expects(:rand).with(0).returns(random_value)
  
    assert_equal :current_sequence, Chromosome.send(:read_from, :current_sequence, :xover_freq)
  end    
    
  def test_read_from__returns_alternate_sequence__default_xover_freq 
    random_value = mock
    random_value.expects(:<).with(Chromosome::DEFAULT_XOVER_FREQ).returns(true)
    Chromosome.expects(:rand).with(0).returns(random_value)
    Chromosome.expects(:flip).with(:current_sequence).returns(:alternate_sequence)
  
    assert_equal :alternate_sequence, Chromosome.send(:read_from, :current_sequence)
  end

  def test_flip
    assert_equal 0, Chromosome.send(:flip, 1)
    assert_equal 1, Chromosome.send(:flip, 0)
  end
end