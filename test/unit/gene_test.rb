require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class GeneTest < Test::Unit::TestCase
  def setup
    Petri.stubs(:image_dimensions).returns(Point.new(640, 480))
    Petri.stubs(:num_points).returns(3)

    @gene = Gene.new
  end

  def test_true
    assert true
  end

  def test_polygon_has_extra_methods
    assert @gene.polygon.respond_to?(:num_points)
    assert @gene.polygon.respond_to?(:points)
  end
  
  def test_polygon_has_correct_setup
    @gene.polygon.points.each do |point|
      assert point.class   == Point
      assert point.x.class == Trait
      assert point.y.class == Trait
    end
  end
  
  def test_color_has_correct_setup
    [:r, :g, :b, :a].each do |channel|
      assert_equal Trait, @gene.color.send(channel).class
    end
  end
  
  def test_initialize__no_default_values
    image_dimensions = Point.new(640, 480)
    
    assert_equal 3, @gene.polygon.num_points
    
    @gene.polygon.points.each do |point|
      assert((0...image_dimensions.x) === point.x.value)
      assert((0...image_dimensions.y) === point.y.value)
    end
 
    @gene.color.rgb.each do |channel|
      assert((0.0..1.0) === channel.value)
    end
  end
  
  def test_initialize__with_block
    gene = Gene.new do
      point_1_x { set_value 100 }
      
      point_2 100, 100
      
      trait_r { set_value 100 }
    end
    
    lambda do |index|
      assert gene.polygon[index].x.is_a?(Trait)
      assert gene.polygon[index].y.is_a?(Trait)
    end | Petri.num_points.times
    
    lambda do |trait_name|
      assert gene.color.send(trait_name).is_a?(Trait)
    end | %w[r g b a]
    
    assert_equal 100, gene.polygon[1].x.value
    assert_equal 100, gene.polygon[2].x.value
    assert_equal 100, gene.polygon[2].y.value
    assert_equal 100, gene.color.r.value
    
    assert_raise NoMethodError do
      Gene.new(3, Point.new(640, 480)) { rawr! }
    end
  end
end