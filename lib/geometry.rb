module Geometry    
  def hulled_sequence
    format_points_in(hull)
  end
  
  private
  
  def hull
    ensure_hullable_with(polygon)

    list_of_points = polygon.sort_by { |point| point.x.value }
    left_point     = list_of_points.shift
    right_point    = list_of_points.pop
    determinant    = determinant_function(left_point, right_point)

    lower_list, upper_list = [left_point], [left_point]
    lower_hull, upper_hull = [], []

    partition_points_from(list_of_points, lower_list, upper_list, determinant)

    trim_hull(lower_hull, lower_list << right_point, true)
    trim_hull(upper_hull, upper_list << right_point, false)

    lower_hull + upper_hull.reverse[1..-2]
  end
  
  def ensure_hullable_with(points)
    assert_at_least 3, points.length, "Can not calculate the convex hull unless there are at least 3 points (#{points.size} #{points.size == 1 ? 'was' : 'were'} provided)"
  end
  
  def partition_points_from(list_of_points, lower_list, upper_list, determinant_lambda)
    until list_of_points.empty?
      point = list_of_points.shift
      (determinant_lambda[point] < 0 ? lower_list : upper_list) << point
    end
  end
  
  def trim_hull(hull, list, xor_boolean)
    until list.empty?
      hull << list.shift
      while hull.size >= 3 && !convex?(hull.last(3), xor_boolean)
        hull[-2] = hull[-1]
        hull.pop
      end
    end
  end

  def determinant_function(point_1, point_2)
    # This is a good candidate for functionals.rb apply_head.
    lambda { |pivot| multiply_difference(point_1, point_2, pivot) - multiply_difference(pivot, point_2, point_1) }
  end
  
  def multiply_difference(point_1, point_2, point_3)
    (point_1.x.value - point_2.x.value) * (point_3.y.value - point_2.y.value)
  end

  def convex?(points, xor_boolean)
    (determinant_function(points[0], points[2])[points[1]] > 0) ^ xor_boolean
  end
  
  def format_points_in(array)
    array.inject([]) { |list, point| list << point.x.value << point.y.value }
  end
end