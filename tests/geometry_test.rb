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
    
    assert_equal true, Geometry.clockwise?(point_1, point_2, point_3)
  end
  
  def test_clockwise__points_are_counter_clockwise
    # Point locations: 1  3
    #                     2
    
    point_1 = create_point(0,  0)
    point_2 = create_point(50, 50)
    point_3 = create_point(50, 0)
    
    assert_equal false, Geometry.clockwise?(point_1, point_2, point_3)
  end
  
  def test_clockwise__three_points_on_a_line_are_not_considered_clockwise
    # Point locations: 1
    #                  2
    #                  3

    point_1 = create_point(0,  0)
    point_2 = create_point(0, 25)
    point_3 = create_point(0, 50)

    assert_equal false, Geometry.clockwise?(point_1, point_2, point_3)
  end
    
  def test_clockwise__points_have_same_location
    # Point locations: (1, 2, 3 at same position)
    
    assert_equal false, Geometry.clockwise?(create_point(0, 0), create_point(0, 0), create_point(0, 0))
  end
  
  def test_left_of_line__line_first_in_params
    # Point locations: 1  3
    #                     2
    
    line  = [create_point(0, 0), create_point(50, 50)]
    point = create_point(50, 0)
    assert_equal false, Geometry.clockwise?(line.first, line.last, point)
    
    # Point locations: 1
    #                  3  2
    
    line  = [create_point(0, 0), create_point(50, 50)]
    point = create_point(0, 50)
    assert_equal true, Geometry.clockwise?(line.first, line.last, point)
  end
     
  def test_left_of_line__point_first_in_params
    # Point locations: 2  1
    #                     3
    
    point = create_point(50, 0)
    line  = [create_point(0, 0), create_point(50, 50)]
    assert_equal false, Geometry.clockwise?(point, line.first, line.last)
    
    # Point locations: 2
    #                  1  3
    
    point = create_point(0, 50)
    line  = [create_point(0, 0), create_point(50, 50)]
    assert_equal true, Geometry.clockwise?(point, line.first, line.last)
  end
  
  def test_point_inside_hull__point_in_hull
    # Point locations:    1
    #                     4
    #                  3     2
    
    point_1 = create_point(25, 0)
    point_2 = create_point(50, 50)
    point_3 = create_point(0,  50)
    deque   = [point_3, point_1, point_2, point_3]
    
    point_4 = create_point(25, 25)
    
    assert_nil Geometry.point_inside_hull?(point_4, deque)
  end
  
  def test_point_inside_hull__point_on_hull
    # Point locations: 1
    #                  4
    #                  3     2

    point_1 = create_point(0,  0)
    point_2 = create_point(50, 50)
    point_3 = create_point(0,  50)
    deque   = [point_3, point_1, point_2, point_3]
    
    point_4 = create_point(0, 25)
    
    assert_equal point_4, Geometry.point_inside_hull?(point_4, deque)
  end
  
  def test_point_inside_hull__point_outside_hull
    # Point locations:    1
    #                  4
    #                  3     2
    
    point_1 = create_point(25, 0)
    point_2 = create_point(50, 50)
    point_3 = create_point(0,  50)
    deque   = [point_3, point_1, point_2, point_3]
    
    point_4 = create_point(0, 25)
    
    assert_equal point_4, Geometry.point_inside_hull?(point_4, deque)
  end
      
  def test_point_inside_hull__test_conditional_logic
    Geometry.stubs(:clockwise?).returns(false, false)
    assert_equal :point, Geometry.point_inside_hull?(:point, [])
    
    Geometry.stubs(:clockwise?).returns(true, false)
    assert_equal :point, Geometry.point_inside_hull?(:point, [])
    
    Geometry.stubs(:clockwise?).returns(false, true)
    assert_equal :point, Geometry.point_inside_hull?(:point, [])
    
    Geometry.stubs(:clockwise?).returns(true, true)
    assert_nil Geometry.point_inside_hull?(:point, [])
  end
      
  def test_initialize_deque
    Geometry.expects(:clockwise?).with(:point_1, :point_2, :point_3).returns(false)
    assert_equal [:point_3, :point_1, :point_2, :point_3], Geometry.initialize_deque(:point_1, :point_2, :point_3)

    Geometry.expects(:clockwise?).with(:point_1, :point_2, :point_3).returns(true)
    assert_equal [:point_2, :point_1, :point_3, :point_2], Geometry.initialize_deque(:point_1, :point_2, :point_3)
  end
  
  protected
  
  def create_point(x, y)
    Point.new(
      Trait.new(:x, (0...100), :default => x),
      Trait.new(:y, (0...100), :default => y)
    )
  end
end