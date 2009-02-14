require "test/unit"
require "rubygems"
require "mocha"
require "../objects/chromosome.rb"

class CalculatorTest < Test::Unit::TestCase
  def test_true
    assert true
  end

  def test_get_normal_random_variable__x
    sum = mock
    sum.expects(:+).with(:y).returns(sum)
    sum.expects(:<).with(1).returns(true)
    
    x = mock
    x.expects(:**).with(2).returns(sum)
    y = mock
    y.expects(:**).with(2).returns(:y)
    
    Calculator.expects(:get_uniform_random_variable).twice.returns(x, y)
    Calculator.expects(:rand).with(2).returns(0)
    Calculator.expects(:convert).with(x, sum)
    
    Calculator.get_normal_random_variable
  end

  def test_get_normal_random_variable__y
    sum = mock
    sum.expects(:+).with(:y).returns(sum)
    sum.expects(:<).with(1).returns(true)
    
    x = mock
    x.expects(:**).with(2).returns(sum)
    y = mock
    y.expects(:**).with(2).returns(:y)
    
    Calculator.expects(:get_uniform_random_variable).twice.returns(x, y)
    Calculator.expects(:rand).with(2).returns(1)
    Calculator.expects(:convert).with(y, sum)
    
    Calculator.get_normal_random_variable
  end

  def test_get_normal_random_variable__loops_until_sum_is_less_than_one
    sum = mock
    sum.expects(:+).with(:y).returns(sum)
    sum.expects(:<).with(1).returns(true)
    
    x = mock
    x.expects(:**).with(2).returns(sum)
    y = mock
    y.expects(:**).with(2).returns(:y)
    
    Calculator.expects(:get_uniform_random_variable).times(4).returns(1, 1, x, y)
    Calculator.expects(:rand).with(2).returns(0)
    Calculator.expects(:convert).with(x, sum)
    
    Calculator.get_normal_random_variable
  end

  def test_get_uniform_random_variable
    random_value = mock
    random_value.expects(:*).with(:sign)
    Calculator.expects(:rand).with(0).returns(random_value)
    Calculator.expects(:random_sign_change).returns(:sign)
    
    Calculator.get_uniform_random_variable
  end
  
  def test_random_sign_change
    Calculator.expects(:rand).with(2).returns(0)
    assert_equal 1, Calculator.random_sign_change
    
    Calculator.expects(:rand).with(2).returns(1)
    assert_equal -1, Calculator.random_sign_change
  end
  
  def test_convert
    assert_equal 0, Calculator.convert(1, 0)
    assert_equal 0, Calculator.convert(0, 0)
    assert_equal 0, Calculator.convert(0, 1)
  end

  def test_generate_value__raises_error_when_max_is_nil_or_zero
    assert_raise ArgumentError do 
      Calculator.generate_value(nil) 
    end
    
    assert_raise ArgumentError do 
      Calculator.generate_value(0) 
    end
  end
  
  def test_generate_value__returns_same_type_as_max    
    assert Calculator.generate_value(1.0).is_a?(Float)
    assert Calculator.generate_value(100).is_a?(Fixnum)
  end
  
  def test_meiosis
    num_genes  = 100
    num_points = 10
    image_dimensions = Point.new(640, 480)
    chromosome_1 = Chromosome.new(num_genes, num_points, image_dimensions)
    chromosome_2 = Chromosome.new(num_genes, num_points, image_dimensions)
    
    chromosome_1.expects(:get_parameters).twice.returns(:params, [num_genes, num_points, image_dimensions])
    chromosome_2.expects(:get_parameters).returns(:params)
    
    chromosome_1.expects(:fitness).twice.returns(:value)
    chromosome_2.expects(:fitness).twice.returns(:value)
    
    Calculator.expects(:read_from).times(num_genes).returns(0)
    Calculator.expects(:generate_gene_from).times(num_genes).returns({})
    
    new_chromosome = Calculator.meiosis(chromosome_1, chromosome_2)
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
      Calculator.meiosis(chromosome_1, chromosome_2)
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
      Calculator.meiosis(chromosome_1, chromosome_2)
    end
  end
  
  def test_generate_gene_from
    Calculator.stubs(:rand).returns(stub(:< => false)) # Ensures self.mutate(trait) returns the original trait.

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
    assert_equal options, Calculator.generate_gene_from(gene, :fitness)
  end
  
  def test_settings_hash_for
    Trait.expects(:new_standard_deviation_from).with(:fitness).returns(:new_standard_deviation)
    
    Calculator.expects(:mutate).with(:trait, :mutation_freq).returns(:value)
    
    expected_hash = { :default => :value, :standard_deviation => :new_standard_deviation }
    assert_equal expected_hash, Calculator.settings_hash_for(:trait, :fitness, :mutation_freq)
  end
        
  def test_settings_hash_for__default_mutation_freq
    Trait.expects(:new_standard_deviation_from).with(:fitness).returns(:new_standard_deviation)
    
    Calculator.expects(:mutate).with(:trait, Calculator::DEFAULT_MUTATION_FREQ).returns(:value)
    
    expected_hash = { :default => :value, :standard_deviation => :new_standard_deviation }
    assert_equal expected_hash, Calculator.settings_hash_for(:trait, :fitness)
  end

  def test_mutate__returns_normal_trait_value
    trait = Trait.new(:x, (0..255), :default => 100)
    
    random_value = mock
    random_value.expects(:<).with(:mutation_freq).returns(false)
    Calculator.expects(:rand).with(0).returns(random_value)
    
    assert_equal 100, Calculator.mutate(trait, :mutation_freq)
  end
      
  def test_mutate__returns_mutated_trait_value__default_mutation_freq
    trait = Trait.new(:x, (0..255), :default => 100)
    trait.expects(:mutated_value).returns(:random_value)
    
    random_value = mock
    random_value.expects(:<).with(Calculator::DEFAULT_MUTATION_FREQ).returns(true)
    Calculator.expects(:rand).with(0).returns(random_value)
    
    assert_equal :random_value, Calculator.mutate(trait)
  end

  def test_read_from__returns_current_sequence    
    random_value = mock
    random_value.expects(:<).with(:xover_freq).returns(false)
    Calculator.expects(:rand).with(0).returns(random_value)
    
    assert_equal :current_sequence, Calculator.read_from(:current_sequence, :xover_freq)
  end    
      
  def test_read_from__returns_alternate_sequence__default_xover_freq 
    random_value = mock
    random_value.expects(:<).with(Calculator::DEFAULT_XOVER_FREQ).returns(true)
    Calculator.expects(:rand).with(0).returns(random_value)
    Calculator.expects(:flip).with(:current_sequence).returns(:alternate_sequence)
    
    assert_equal :alternate_sequence, Calculator.read_from(:current_sequence)
  end

  def test_flip
    assert_equal 0, Calculator.flip(1)
    assert_equal 1, Calculator.flip(0)
  end

  protected
  
  def mutate_distribution_helper
    trait = Trait.new(:x, (0..255), { :default => 10, :standard_deviation => 0.25})
    distribution = trait.range.map { 0 }
    
    1000.times do
      value = Calculator.mutate(trait, 0.25)
      distribution[value] += 1
    end
    
    sum = distribution.inject(0.0) { |sum, value| sum + value }
    p distribution.map { |value| value / sum * 100 }
  end
end