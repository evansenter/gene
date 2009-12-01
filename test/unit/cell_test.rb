require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class CellTest < Test::Unit::TestCase
  def setup
    Petri.stubs(:image_dimensions).returns(Point.new(640, 480))
    Petri.stubs(:num_genes).returns(3)
    Petri.stubs(:num_points).returns(3)
    
    @cell = Cell.new
  end
  
  def test_true
    assert true
  end

  def test_initialize
    image_range_x = 0...Petri.image_dimensions.x
    image_range_y = 0...Petri.image_dimensions.y
    channel_range = 0.0..1.0

    @cell.genes.each do |gene|      
      assert_equal Petri.num_points, gene.polygon.num_points
      
      assert gene.polygon.points.all? { |point| image_range_x.include?(point.x.value) && image_range_y.include?(point.y.value) }
      assert gene.color.each_pair { |channel, trait| channel_range.include?(trait.value) }
    end
  end
  
  def test_initialize__with_block
    lambda { |index| assert Cell.new.genes[index].is_a?(Gene) } | Petri.num_genes.times
    
    assert_raise NoMethodError do
      Cell.new { rawr! }
    end
  end
  
  def test_genes_by_alpha
    cell = Cell.new do
      gene_0 do
        trait_a do
          set_value 0.5
        end
      end
      gene_1 do
        trait_a do
          set_value 0.0
        end
      end
      gene_2 do
        trait_a do
          set_value 1.0
        end
      end
    end
    
    assert_equal [0.5, 0.0, 1.0], cell.genes.map(&:color).map(&:a).map(&:value)    
    assert_equal [1.0, 0.5, 0.0], cell.genes_by_alpha.map(&:color).map(&:a).map(&:value)
  end
  
  def test_genes_from_alignment_map
    cell = Cell.new
    assert_equal [cell.genes[2], cell.genes[0], cell.genes[1]], cell.genes_from_alignment_map([2, 0, 1])
  end
end