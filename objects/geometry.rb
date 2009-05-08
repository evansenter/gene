class Geometry
  def self.hull(points)
    return points unless points.length >= 3
    
    list_of_points = points.sort_by { |point| point.x.value }
    left_point     = list_of_points.shift
    right_point    = list_of_points.pop
    determinant    = determinant_function(left_point, right_point)
    
    lower_list, upper_list = [left_point], [left_point]
    lower_hull, upper_hull = [], []
    
    until list_of_points.empty?
      point = list_of_points.shift
      (determinant[point] < 0 ? lower_list : upper_list) << point
    end
    
    trim_hull(lower_hull, lower_list << right_point, true)
    trim_hull(upper_hull, upper_list << right_point, false)
    
    lower_hull + upper_hull.reverse[1..-2]
  end

  private
  
  def self.trim_hull(hull, list, xor_boolean)
    until list.empty?
      hull << list.shift
      while hull.size >= 3 && !convex?(hull.last(3), xor_boolean)
        hull[-2] = hull[-1]
        hull.pop
      end
    end
  end

  def self.determinant_function(point_1, point_2)
    proc { |pivot| ((point_1.x.value - point_2.x.value) * (pivot.y.value - point_2.y.value)) - ((pivot.x.value - point_2.x.value) * (point_1.y.value - point_2.y.value)) }
  end

  def self.convex?(points, xor_boolean)
    (determinant_function(points[0], points[2])[points[1]] > 0) ^ xor_boolean
  end
end