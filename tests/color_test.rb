require "test/unit"
require "rubygems"
require "mocha"
require "../objects/color.rb"

class CalculatorTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_convert
    color_1 = Color.new(1, 2, 3, 4)
    color_2 = Color.new(5, 6, 7, 8)
    
    assert_equal 1, color_1.r
    assert_equal 5, color_2.r
    
    assert_equal 2, color_1.g
    assert_equal 6, color_2.g
    
    assert_equal 3, color_1.b
    assert_equal 7, color_2.b
    
    assert_equal 4, color_1.a
    assert_equal 8, color_2.a
  end
  
  def test_to_hash
    color = Color.new(1, 2, 3, 4)
    expected_hash = {
      :r => color.r,
      :g => color.g,
      :b => color.b,
      :a => color.a
    }
    
    assert_equal expected_hash, color.to_hash
  end
end