require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class PetriTest < Test::Unit::TestCase
  def setup
    # Don't make a petri here.
  end
  
  def test_true
    assert true
  end
  
  def test_prepare_image
    petri = setup_petri
    assert_equal Magick::Image, petri.target_image.class
    assert_equal Point.new(600, 800), Petri.image_dimensions
  end
  
  def test_initialize__with_block
    Petri.new(test_image_path) do
      set_num_cells  1
      set_num_genes  2
      set_num_points 3
    end
    
    assert_equal 3, Petri.num_cells
    assert_equal 2, Petri.num_genes
    assert_equal 3, Petri.num_points
    
    assert_raise NoMethodError do
      Petri.rawr!
    end
    
    assert_raise NoMethodError do
      Petri.new(test_image_path) { set_num_cells 1 }.rawr!
    end
  end
  
  def test_initialize
    petri = Petri.new(test_image_path)
    
    assert_equal 30, Petri.num_cells
    assert_equal 50, Petri.num_genes
    assert_equal  3, Petri.num_points
    
    assert_equal 30, petri.dish.size
    assert petri.dish.all? { |cell| cell.is_a?(Cell) }
  end
  
  def test_initialize__num_cells_divisible_by_three
    [1, 2, 3].each do |i|
      assert_equal 3, Petri.new(test_image_path) { set_num_cells i }.num_cells
    end
        
    assert_equal 6, Petri.new(test_image_path) { set_num_cells 4 }.num_cells
  end
  
  def test_round
    petri = setup_petri
    assert_equal 0, petri.round
    
    petri.send(:next_round)
    assert_equal 1, petri.round
    
    petri.send(:next_round)
    assert_equal 2, petri.round
  end
  
  private
  
  def setup_petri
    Petri.new(test_image_path) { set_num_cells 1 }
  end
  
  def test_image_path
    File.join(File.dirname(__FILE__), "..", "assets", "Nova.jpg")
  end
end