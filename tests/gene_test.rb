%w[test/unit rubygems mocha ../objects/gene.rb].each { |helper| require helper }

class GeneTest < Test::Unit::TestCase
  def setup
    points = 4
    @gene = Gene.new(points, Point.new(100, 100))
  end
  
  def test_setup__exception_when_less_than_three_points
    assert_raise ArgumentError do
      @gene = Gene.new(0, Point.new(100, 100))
    end
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
  
  def test_color_has_extra_methods
    assert @gene.color.respond_to?(:rgb)
    assert @gene.color.respond_to?(:a)
  end
  
  def test_color_has_correct_setup
    [:r, :g, :b, :a].each do |vector|
      assert_equal Trait, @gene.color.send(vector).class
    end

    assert_equal [@gene.color.r, @gene.color.g, @gene.color.b], @gene.color.rgb
  end
  
  def test_initialize__no_default_values
    points = 10
    image_dimensions = Point.new(640, 480)
    gene = Gene.new(points, image_dimensions)
    
    assert_equal 10, gene.polygon.num_points
    
    gene.polygon.points.each do |point|
      assert((0...image_dimensions.x) === point.x.value)
      assert((0...image_dimensions.y) === point.y.value)
    end
 
    gene.color.rgb.each do |vector|
      assert((0...256) === vector.value)
    end
  end
end