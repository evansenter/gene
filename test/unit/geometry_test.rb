require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class TestClass
  include Geometry
end

class GeometryTest < Test::Unit::TestCase
  def setup
    @test_class = TestClass.new
  end
  
  def test_true
    assert true
  end
  
  def test_hull__less_than_three_points
    point_list = [[], [create_point(0, 0)], [create_point(0, 0), create_point(0, 0)]]
    
    point_list.each do |point_list|
      assert_raise ArgumentError do
        @test_class.hull(point_list)
      end
    end
  end
  
  def test_hull_simple_case
    point_list = [create_point(0, 0), create_point(50, 0), create_point(50, 50)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(@test_class.hull(point_list))
  end
  
  def test_hull__one_point_inside
    point_list = [create_point(0, 0), create_point(50, 0), create_point(50, 50), create_point(10, 5)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(@test_class.hull(point_list))
  end
  
  def test_hull__three_points_on_a_line
    point_list = [create_point(0, 0), create_point(25, 0), create_point(50, 0), create_point(50, 50)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(@test_class.hull(point_list))    
  end
  
  def test_hull__three_points_on_a_line_with_one_point_inside
    point_list = [create_point(0, 0), create_point(25, 0), create_point(50, 0), create_point(50, 50), create_point(10, 5)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(@test_class.hull(point_list))    
  end
  
  protected
  
  def create_point(x, y)
    Point.new(
      Trait.new(:x, (0...100)) { set_value x },
      Trait.new(:y, (0...100)) { set_value y }
    )
  end
  
  def format_points_in(array)
    array.map { |point| [point.x.value, point.y.value] }
  end
end