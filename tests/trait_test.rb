require "test/unit"
require "rubygems"
require "mocha"
require "../objects/trait.rb"

class TraitTest < Test::Unit::TestCase
  def test_true
    assert true
  end

  def test_initialize__raises_error
    assert_raise ArgumentError do 
      Trait.new(:x)
    end
  end
  
  def test_initialize__method_aliases_are_singleton_methods
    trait_1 = Trait.new(:x, (0...100), :default => 10)
    trait_2 = Trait.new(:y, (0...100), :default => 20)
    
    assert_equal 10, trait_1.x
    assert_raises NoMethodError do
      trait_1.y
    end
  end
    
  def test_initialize__value_namespace_doesnt_overlap_in_instances
    trait_1 = Trait.new(:x, (0...100), :default => 10)
    trait_2 = Trait.new(:x, (0...100), :default => 20)
    
    assert_equal 10, trait_1.x
    assert_equal 20, trait_2.x
    assert_equal 10, trait_1.x
  end
  
  def test_named_value_and_value_return_the_same_thing
    trait_1 = Trait.new(:x, (0...100), :default => 10)
    assert_equal trait_1.x, trait_1.value
  end

  def test_standard_deviation__default
    assert_equal 1.0, Trait.new(:test, (0..10)).standard_deviation
    assert_equal 0.9, Trait.new(:test, (0...10)).standard_deviation
  end

  def test_standard_deviation__provided
    assert_equal 5.0, Trait.new(:test, (0..10), :standard_deviation => 0.5).standard_deviation
    assert_equal 4.5, Trait.new(:test, (0...10), :standard_deviation => 0.5).standard_deviation
  end
  
  def test_setup_range_with__integer__max_and_min
    assert_equal 10, Trait.new(:x, (0..10)).range.max
    assert_equal 9,  Trait.new(:x, (0...10)).range.max

    assert_equal 1,  Trait.new(:x, (1..10)).range.min
    assert_equal 1,  Trait.new(:x, (1...10)).range.min
  end  
  
  def test_setup_range_with__float__max_and_min
    assert_equal 1.0, Trait.new(:x, (0.0..1.0)).range.max
    assert_equal 1.0, Trait.new(:x, (0.0...1.0)).range.max

    assert_equal 0.0, Trait.new(:x, (0.0..1.0)).range.min
    assert_equal 0.0, Trait.new(:x, (0.0...1.0)).range.min
  end
  
  def test_setup_standard_deviation_with__provided
    trait = Trait.new(:x, (0..10), :standard_deviation => 1)
    assert_equal trait.range.max, trait.standard_deviation
  end
    
  def test_setup_standard_deviation_with__default
    trait = Trait.new(:x, (0..10))
    assert_equal Trait::DEFAULT_STANDARD_DEVIATION * trait.range.max, trait.standard_deviation
  end
  
  def test_setup_value_with
    Range.any_instance.expects(:include?).returns(true)
    
    trait = Trait.new(:x, (0..10), :default => :value)
    
    assert_equal :value, trait.value
  end
  
  def test_setup_value_with__no_value
    Calculator.expects(:generate_value).returns(:value)
    
    trait = Trait.new(:x, (0..10))
    
    assert_equal :value, trait.value
  end
  
  def test_setup_value_with__raises_error_if_out_of_range
    assert_raise ArgumentError do
      Trait.new(:x, (0..10), :default => 100)
    end
    
    assert_raise ArgumentError do
      Trait.new(:x, (0..10), :default => -100)
    end
  end

  def test_mutate__integer
    1000.times do
      trait = Trait.new(:x, (0..100))
      new_value = trait.mutated_value
      
      assert_equal Fixnum, new_value.class
    end
  end
  
  def test_mutate__inclusive
    1000.times do
      trait = Trait.new(:x, (0..100))
      old_value = trait.value
      new_value = trait.mutated_value
      
      assert trait.range === new_value
      assert_equal old_value, trait.value
    end
  end
  
  def test_mutate__exclusive
    1000.times do
      trait = Trait.new(:x, (0...100))
      old_value = trait.value
      new_value = trait.mutated_value
      
      assert trait.range === new_value
      assert_equal old_value, trait.value
    end
  end
end