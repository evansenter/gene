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
    @hungarian.instance_variable_set(:@matrix, [[1, 2, 3], [1, 0, 1], [2, 2, 2]])
    @hungarian.send(:minimize_rows)
    assert_equal [[0, 1, 2], [1, 0, 1], [0, 0, 0]], @hungarian.instance_variable_get(:@matrix)
  end
  
  def test_star_zeroes
    @hungarian.instance_variable_set(:@matrix, [[0, 0], [0, 0]])
    @hungarian.expects(:reset_covered_hash)
    
    assert_equal [[Hungarian::EMPTY, Hungarian::EMPTY], [Hungarian::EMPTY, Hungarian::EMPTY]], @hungarian.instance_variable_get(:@mask)
    expected_hash = {:rows => [false, false], :columns => [false, false]}
    assert_equal expected_hash, @hungarian.instance_variable_get(:@covered)
    
    @hungarian.send(:star_zeroes)
    
    assert_equal [[Hungarian::STAR, Hungarian::EMPTY], [Hungarian::EMPTY, Hungarian::STAR]], @hungarian.instance_variable_get(:@mask)
    expected_hash = {:rows => [true, true], :columns => [true, true]}
    assert_equal expected_hash, @hungarian.instance_variable_get(:@covered)
  end
  
  def test_mask_columns
    
  end

  def test_prime_zeroes
    
  end
  
  def test_augment_path
    
  end
  
  def test_adjust_matrix
    
  end

  def test_assignment
    @hungarian.instance_variable_set(:@mask, [[Hungarian::STAR, Hungarian::EMPTY], [Hungarian::EMPTY, Hungarian::STAR]])
    assert_equal [[0, 0], [1, 1]], @hungarian.send(:assignment)
    
    @hungarian.instance_variable_set(:@mask, [[Hungarian::EMPTY, Hungarian::STAR], [Hungarian::STAR, Hungarian::EMPTY]])
    assert_equal [[0, 1], [1, 0]], @hungarian.send(:assignment)
  end

  def test_update_elements_in_path
    @hungarian.instance_variable_set(:@mask, [[Hungarian::STAR, Hungarian::EMPTY], [Hungarian::EMPTY, Hungarian::PRIME]])
    @hungarian.send(:update_elements_in, [[0, 0], [1, 1]])
    assert_equal [[Hungarian::EMPTY, Hungarian::EMPTY], [Hungarian::EMPTY, Hungarian::STAR]], @hungarian.instance_variable_get(:@mask)
  end

  def test_find_uncovered_zero
    hungarian = Hungarian.new([[0, 0], [0, 0]])
    hungarian.instance_variable_set(:@covered, {:rows => [false, true], :columns => [false, true]})
    assert_equal [0, 0], hungarian.send(:find_uncovered_zero)
    
    hungarian = Hungarian.new([[0, 0], [0, 0]])
    hungarian.instance_variable_set(:@covered, {:rows => [true, false], :columns => [true, false]})
    assert_equal [1, 1], hungarian.send(:find_uncovered_zero)
  end
  
  def test_find_uncovered_zero__cell_skipped_if_value_nonzero__default_returned
    hungarian = Hungarian.new([[1, 1], [1, 1]])
    assert_equal [-1, -1], hungarian.send(:find_uncovered_zero)    
  end
  
  def test_cover_cell
    @hungarian.instance_variable_set(:@covered, {:rows => [false, false], :columns => [false, false]})
    @hungarian.send(:cover_cell, 0, 0)
    
    expected_hash = {:rows => [true, false], :columns => [true, false]}
    assert_equal expected_hash, @hungarian.instance_variable_get(:@covered)
  end
  
  def test_reset_covered_hash
    @hungarian.instance_variable_set(:@covered, {:rows => [true, false], :columns => [true, false]})
    @hungarian.send(:reset_covered_hash)
    
    expected_hash = {:rows => [false, false], :columns => [false, false]}
    assert_equal expected_hash, @hungarian.instance_variable_get(:@covered)
  end
  
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
 
  def test_indices_of_covered_rows
    @hungarian.instance_variable_set(:@length, 3)
    @hungarian.instance_variable_set(:@covered, {:rows => [true, false, true], :columns => [true, false, true]})
    assert_equal [0, 2], @hungarian.send(:indices_of_covered_rows)
  end
  
  def test_indices_of_uncovered_columns
    @hungarian.instance_variable_set(:@length, 3)
    @hungarian.instance_variable_set(:@covered, {:rows => [false, true, false], :columns => [false, true, false]})
    assert_equal [0, 2], @hungarian.send(:indices_of_uncovered_columns)
  end
  
  def test_traverse_indices
    traversal = []
    @hungarian.send(:traverse_indices) { |row, column| traversal << [row, column] }
    assert_equal [[0, 0], [0, 1], [1, 0], [1, 1]], traversal
  end
  
  def test_index_range
    assert_equal (0...2), @hungarian.send(:index_range)
  end
end