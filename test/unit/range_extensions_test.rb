require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class RangeExtensionsTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_add_bounding_methods_to__integer_range__max_and_min
    inclusive_range = (0..10)
    exclusive_range = (0...10)
  
    assert_equal 0,  inclusive_range.min
    assert_equal 10, inclusive_range.max

    assert_equal 0,  exclusive_range.min
    assert_equal 9,  exclusive_range.max
  end  

  def test_add_bounding_methods_to__float_range__max_and_min
    inclusive_range = (0.0..1.0)
    exclusive_range = (0.0...1.0)
  
    assert_equal 0.0, inclusive_range.min
    assert_equal 1.0, inclusive_range.max

    assert_equal 0.0, exclusive_range.min
    assert_equal 1.0, exclusive_range.max
  end
end