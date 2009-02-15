%w[test/unit rubygems mocha ../objects/extensions.rb].each { |helper| require helper }

class ExtensionsTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_returning
    return_value = returning(1) { nil }
    assert_equal 1, return_value
  end
  
  def test_add_bounding_methods_to__integer_range__max_and_min
    inclusive_range = (0..10)
    exclusive_range = (0...10)
    
    add_bounding_methods_to(inclusive_range)
    add_bounding_methods_to(exclusive_range)
    
    assert_equal 10, inclusive_range.max
    assert_equal 0,  inclusive_range.min

    assert_equal 9,  exclusive_range.max
    assert_equal 0,  exclusive_range.min
  end  
  
  def test_add_bounding_methods_to__float_range__max_and_min
    inclusive_range = (0.0..1.0)
    exclusive_range = (0.0...1.0)
    
    add_bounding_methods_to(inclusive_range)
    add_bounding_methods_to(exclusive_range)
    
    assert_equal 1.0, inclusive_range.max
    assert_equal 0.0, inclusive_range.min

    assert_equal 1.0, exclusive_range.max
    assert_equal 0.0, exclusive_range.min
  end
  
  def test_symbol_to_proc
    arrays = [Array.new(0), Array.new(1), Array.new(2)]
    assert_equal [0, 1, 2], arrays.map(&:size)
  end
end