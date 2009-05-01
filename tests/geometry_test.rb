%w[test/unit rubygems mocha ../objects/geometry.rb ../objects/point.rb ../objects/trait.rb].each { |helper| require helper }

class GeometryTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_hull__one_point_inside
    point_list = [create_point(0, 0), create_point(50, 0), create_point(50, 50), create_point(45, 45)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(Geometry.hull(point_list))
  end
  
  protected
  
  def create_point(x, y)
    Point.new(
      Trait.new(:x, (0...100), :default => x),
      Trait.new(:y, (0...100), :default => y)
    )
  end
  
  def format_points_in(array)
    array.map { |point| [point.x.value, point.y.value] }
  end
end