require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class GeometryTest < Test::Unit::TestCase
  class TestClass
    include Geometry

    attr_accessor :polygon
  end
  
  def setup
    @test_class = TestClass.new
  end
  
  def test_true
    assert true
  end
  
  def test_hull__less_than_three_points
    point_lists = [[], [create_point(0, 0)], [create_point(0, 0), create_point(0, 0)]]
    
    point_lists.each do |point_list|
      assert_raise ArgumentError do
        @test_class.polygon = point_list
        @test_class.hulled_sequence
      end
    end
  end
  
  def test_hull_simple_case
    @test_class.polygon = [create_point(0, 0), create_point(50, 0), create_point(50, 50)]
    assert_equal [0, 0, 50, 50, 50, 0], @test_class.hulled_sequence
  end
  
  def test_hull__one_point_inside
    @test_class.polygon = [create_point(0, 0), create_point(50, 0), create_point(50, 50), create_point(10, 5)]
    assert_equal [0, 0, 50, 50, 50, 0], @test_class.hulled_sequence
  end
  
  def test_hull__three_points_on_a_line
    @test_class.polygon = [create_point(0, 0), create_point(25, 0), create_point(50, 0), create_point(50, 50)]
    assert_equal [0, 0, 50, 50, 50, 0], @test_class.hulled_sequence
  end
  
  def test_hull__three_points_on_a_line_with_one_point_inside
    @test_class.polygon = [create_point(0, 0), create_point(25, 0), create_point(50, 0), create_point(50, 50), create_point(10, 5)]
    assert_equal [0, 0, 50, 50, 50, 0], @test_class.hulled_sequence
  end
  
  protected
  
  def create_point(x, y)
    Point.new(
      Trait.new(0...100) { set_value x },
      Trait.new(0...100) { set_value y }
    )
  end
end