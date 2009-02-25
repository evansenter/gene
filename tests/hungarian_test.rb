require "test/unit"
require "rubygems"
require "mocha"
require "../objects/hungarian.rb"

class TraitTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def setup
    @hungarian = Hungarian.new([[1, 0], [0, 1]])
  end

  def test_minimize_rows
    hungarian = Hungarian.new([[1, 2, 3], [1, 0, 1], [2, 2, 2]])
    expected = [[0, 1, 2], [1, 0, 1], [0, 0, 0]]
    assert_equal expected, hungarian.send(:minimize_rows)
  end

  def test_find_uncovered_zero
    hungarian = Hungarian.new([[0, 0], [0, 0]])
    hungarian.instance_variable_set(:@covered, {:rows => [false, true], :columns => [false, true]})
    assert_equal [0, 0], hungarian.send(:find_uncovered_zero)
    
    hungarian = Hungarian.new([[0, 0], [0, 0]])
    hungarian.instance_variable_set(:@covered, {:rows => [true, false], :columns => [true, false]})
    assert_equal [1, 1], hungarian.send(:find_uncovered_zero)
  end
  
  # Write test to ensure non-zero cells are skipped, and a test for the default value
  
  def test_location_covered
    @hungarian.instance_variable_set(:@covered, {:rows => [false], :columns => [false]})
    assert_equal false, @hungarian.send(:location_covered?, 0, 0)
    
    @hungarian.instance_variable_set(:@covered, {:rows => [true], :columns => [false]})
    assert_equal true, @hungarian.send(:location_covered?, 0, 0)
    
    @hungarian.instance_variable_set(:@covered, {:rows => [false], :columns => [true]})
    assert_equal true, @hungarian.send(:location_covered?, 0, 0)
    
    @hungarian.instance_variable_set(:@covered, {:rows => [true], :columns => [true]})
    assert_equal true, @hungarian.send(:location_covered?, 0, 0)
  end
  
  def test_row_mask_values_for
    @hungarian.instance_variable_set(:@mask, [[0, 1], [2, 3]])
    assert_equal [0, 1], @hungarian.send(:row_mask_values_for, 0)
    assert_equal [2, 3], @hungarian.send(:row_mask_values_for, 1)
  end
    
  def test_column_mask_values_for
    @hungarian.instance_variable_set(:@mask, [[0, 1], [2, 3]])
    assert_equal [0, 2], @hungarian.send(:column_mask_values_for, 0)
    assert_equal [1, 3], @hungarian.send(:column_mask_values_for, 1)
  end
  
  def test_traverse_indices
    traversal = returning([]) { |array| @hungarian.send(:traverse_indices) { |row, column| array << [row, column] } }
    assert_equal [[0, 0], [0, 1], [1, 0], [1, 1]], traversal
  end
end