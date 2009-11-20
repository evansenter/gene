require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class GeneratorTest < Test::Unit::TestCase
  def setup
    @num_genes        = 5
    @num_points       = 3
    @image_dimensions = Point.new(640, 480)
    @chromosome_1     = Chromosome.new(@num_genes, @num_points, @image_dimensions)
    @chromosome_2     = Chromosome.new(@num_genes, @num_points, @image_dimensions)
    @generator        = Generator.new(@chromosome_1, @chromosome_2)
  end
  
  def test_true
    assert true
  end
  
  def test_combine
    assert_equal Chromosome, @generator.combine.class
  end
  
  def test_generate_chromosome_settings
    @num_genes.times.each { |index| @generator.expects(:generate_gene_at).with(index).returns(index) }
    
    expected_settings = returning({}) do |settings_for|
      @num_genes.times.each do |index|
        settings_for[:"gene_#{index}"] = index
      end
    end

    assert_equal expected_settings, @generator.send(:generate_chromosome_settings)
  end
  
  def test_validate_meiosis_for__chromosomes_dont_match
    @chromosome_1.expects(:get_parameters).returns(:chromsome_1)
    @chromosome_2.expects(:get_parameters).returns(:chromsome_2)
  
    @chromosome_1.expects(:fitness).never
    @chromosome_2.expects(:fitness).never
  
    assert_raise ArgumentError do
      @generator.send(:validate_generator)
    end
  end
  
  def test_validate_generator__fitness_missing
    @chromosome_1.expects(:get_parameters).returns(:params)
    @chromosome_2.expects(:get_parameters).returns(:params)
  
    @chromosome_1.expects(:fitness).returns(:value)
    @chromosome_2.expects(:fitness).returns(nil)
  
    assert_raise ArgumentError do
      @generator.send(:validate_generator)
    end
  end
  
  def test_generate_gene_at
    @generator.expects(:read_sequence).returns(0)
    @generator.instance_variable_set(:@mutation_freq, 0)
    
    Trait.stubs(:new_standard_deviation_from).with(anything).returns(:value)
    Trait.any_instance.stubs(:setup_standard_deviation_with)
    
    gene_config = {
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
      
    gene = Gene.new(3, Point.new(640, 480), gene_config)
    
    @generator.instance_variable_set(:@gene_map, [[gene]])
    
    assert_equal gene_config, @generator.send(:generate_gene_at, 0)
  end
  
  def test_settings_hash_for
    @generator.expects(:mutate).with(:trait).returns(:value)
    Trait.expects(:new_standard_deviation_from).with(@generator.fitness_map[@generator.current_sequence]).returns(:deviation)
  
    expected_hash = { :default => :value, :standard_deviation => :deviation }
    assert_equal expected_hash, @generator.send(:settings_hash_for, :trait)
  end
  
  def test_mutate__returns_normal_trait_value
    @generator.instance_variable_set(:@mutation_freq, 0)
    
    trait = mock
    trait.expects(:value)
  
    @generator.send(:mutate, trait)
  end
    
  def test_mutate__returns_mutated_trait_value
    @generator.instance_variable_set(:@mutation_freq, 1)
    
    trait = mock
    trait.expects(:mutated_value)
  
    @generator.send(:mutate, trait)
  end
    
  def test_read_sequence
    @generator.instance_variable_set(:@current_sequence, 0)
    @generator.instance_variable_set(:@xover_freq, 1)
    
    assert_equal 1, @generator.send(:read_sequence)
    assert_equal 0, @generator.send(:read_sequence)
    
    @generator.instance_variable_set(:@xover_freq, 0)
    
    assert_equal 0, @generator.send(:read_sequence)
    
    @generator.instance_variable_set(:@current_sequence, 1)
    
    assert_equal 1, @generator.send(:read_sequence)
  end
end