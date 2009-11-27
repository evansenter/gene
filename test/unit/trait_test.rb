require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class TraitTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_initialize
    x = Trait.new(0...100) { set_value 10 }
    y = Trait.new(0...100) { set_value 20 }
    
    assert_equal 10, x.value
    assert_equal 20, y.value
  end

  def test_standard_deviation__default
    assert_equal 1.0, Trait.new(0..10).standard_deviation
    assert_equal 0.9, Trait.new(0...10).standard_deviation
  end

  def test_standard_deviation__provided
    assert_equal 5.0, Trait.new(0..10) { deviation 0.5 }.standard_deviation
    assert_equal 4.5, Trait.new(0...10) { deviation 0.5 }.standard_deviation
  end
  
  def test_setup_standard_deviation_with__provided
    trait = Trait.new(0..10) { deviation 1 }
    assert_equal trait.range.max, trait.standard_deviation
  end
    
  def test_setup_standard_deviation_with__default
    trait = Trait.new(0..10)
    assert_equal Trait::STANDARD_DEVIATION[:default] * trait.range.max, trait.standard_deviation
  end
  
  def test_setup_value_with
    trait = Trait.new(0..10) { set_value :value }
    
    assert_equal :value, trait.value
  end
  
  def test_setup_value_with__no_value
    Trait.expects(:generate_value).returns(:value)
    
    trait = Trait.new(0..10)
    
    assert_equal :value, trait.value
  end
  
  def test_setup_value_with__raises_error_if_out_of_range
    assert_raise ArgumentError do
      Trait.new(0..10, :default => 100)
    end
    
    assert_raise ArgumentError do
      Trait.new(0..10, :default => -100)
    end
  end

  def test_mutated_value__inclusive
    trait = Trait.new(0..100)
    Trait.stubs(:get_normal_random_variable).returns(1)
    
    trait.instance_variable_set(:@standard_deviation, 1000)
    assert_equal 100, trait.mutated_value
    
    trait.instance_variable_set(:@standard_deviation, -1000)
    assert_equal 0, trait.mutated_value
    
    trait.instance_variable_set(:@standard_deviation, 0)
    assert_equal trait.value, trait.mutated_value
  end
  
  def test_mutated_value__exclusive
    trait = Trait.new(0...100)
    Trait.stubs(:get_normal_random_variable).returns(1)
    
    trait.instance_variable_set(:@standard_deviation, 1000)
    assert_equal 99, trait.mutated_value
  end
  
  def test_percentify
    trait = Trait.new(0..100) { set_value 12 }
    assert_equal "12.0%", trait.percentify
    
    trait = Trait.new(0.0..1.0) { set_value 0.5 }
    assert_equal "50.0%", trait.percentify
  end
  
  def test_new_standard_deviation_from
    trait = Trait.new(0...100)
    
    # The float.to_s is to ensure comparison works.
    assert_equal Trait::STANDARD_DEVIATION[:range].max.to_s, trait.send(:new_standard_deviation_from, 0).to_s
    assert_equal Trait::STANDARD_DEVIATION[:range].min.to_s, trait.send(:new_standard_deviation_from, 1).to_s
  end
end