require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class PetriTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_prepare_image
    dish = Petri.new(:image) { set_num_cells 1 }
    assert_equal :image, dish.original_image
    assert_equal Point.new(640, 480), Petri.image_dimensions
  end
  
  def test_initialize__with_block
    Petri.new(:image) do
      set_num_cells  1
      set_num_genes  2
      set_num_points 3
    end
    
    assert_equal 1, Petri.num_cells
    assert_equal 2, Petri.num_genes
    assert_equal 3, Petri.num_points
    
    assert_raise NoMethodError do
      Petri.rawr!
    end
    
    assert_raise NoMethodError do
      Petri.new(:image) { set_num_cells 1 }.rawr!
    end
  end
  
  def test_initialize
    Petri.new(:image)
    
    assert_equal 30, Petri.num_cells
    assert_equal 50, Petri.num_genes
    assert_equal  3, Petri.num_points
  end
end