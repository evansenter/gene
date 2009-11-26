require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class GeneratorTest < Test::Unit::TestCase
  def setup
    Petri.stubs(:image_dimensions).returns(Point.new(640, 480))
    Petri.stubs(:num_genes).returns(5)
    Petri.stubs(:num_points).returns(3)
    
    @cell_1    = Cell.new
    @cell_2    = Cell.new
    @generator = Generator.new(@cell_1, @cell_2)
  end
  
  def test_true
    assert true
  end
  
  def test_initialize__with_block
    assert_equal Generator::DEFAULT_XOVER_FREQ,    @generator.xover_freq
    assert_equal Generator::DEFAULT_MUTATION_FREQ, @generator.mutation_freq
    
    generator = Generator.new(@cell_1, @cell_2) do
      set_xover_freq    1.0
      set_mutation_freq 1.0
    end
    
    assert_equal 1.0, generator.xover_freq
    assert_equal 1.0, generator.mutation_freq
    
    assert_raise NoMethodError do
      Generator.new(@cell_1, @cell_2) do
        rawr!
      end
    end
  end
  
  def test_combine
    assert_equal Cell, @generator.combine.class
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