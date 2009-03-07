%w[test/unit rubygems mocha ../objects/geometry.rb ../objects/point.rb ../objects/trait.rb].each { |helper| require helper }

class GeometryTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_clockwise
    # Point locations: 1  2
    #                     3

    point_1 = create_point(0,  0)
    point_2 = create_point(50, 0)
    point_3 = create_point(50, 50)
    
    assert_equal :clockwise, Geometry.clockwise?(point_1, point_2, point_3)
  end
  
  def test_clockwise__points_are_counter_clockwise
    # Point locations: 1  3
    #                     2
    
    point_1 = create_point(0,  0)
    point_2 = create_point(50, 50)
    point_3 = create_point(50, 0)
    
    assert_equal :counterclockwise, Geometry.clockwise?(point_1, point_2, point_3)
  end
  
  def test_clockwise__three_points_on_a_line_are_not_considered_clockwise
    # Point locations: 1
    #                  2
    #                  3

    point_1 = create_point(0,  0)
    point_2 = create_point(0, 25)
    point_3 = create_point(0, 50)

    assert_equal :line, Geometry.clockwise?(point_1, point_2, point_3)
  end
    
  def test_clockwise__points_have_same_location
    # Point locations: (1, 2, 3 at same position)
    
    assert_equal :line, Geometry.clockwise?(create_point(0, 0), create_point(0, 0), create_point(0, 0))
  end
  
  protected
  
  def create_point(x, y)
    Point.new(
      Trait.new(:x, (0...100), :default => x),
      Trait.new(:y, (0...100), :default => y)
    )
  end
  
  def format_points_in(array)
    array.map do |point|
      "(#{point.x.value}, #{point.y.value})"
    end.join(", ")
  end
end