require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class PetriTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_prepare_image
    dish = Petri.new(:image)
    assert_equal :image, dish.original_image
    assert_equal Point.new(640, 480), Petri.image_dimensions
  end
  
  def test_initialize__with_block
    Petri.new(:image) do
      set_num_cells  10
      set_num_genes  20
      set_num_points 30
    end
    
    assert_equal 10, Petri.num_cells
    assert_equal 20, Petri.num_genes
    assert_equal 30, Petri.num_points
    
    assert_raise NoMethodError do
      Petri.rawr!
    end
  end
  
  def test_initialize
    Petri.new(:image)
    
    assert_equal 30, Petri.num_cells
    assert_equal 50, Petri.num_genes
    assert_equal  3, Petri.num_points
  end
end