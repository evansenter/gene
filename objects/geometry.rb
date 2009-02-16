require File.join("#{File.dirname(__FILE__)}", "extensions.rb")
require "matrix"

class Geometry
  # Input: a  simple polyline W with n vertices V[i]
  # 
  # Put first 3 vertices onto deque D so that:
  # a) 3rd vertex V[2] is at bottom and top of D
  # b) on D they form a counterclockwise (ccw) triangle
  # 
  # While there are more polyline vertices of W to process
  # Get the next vertex V[i]
  # {
  #     Note that:
  #     a) D is the convex hull of already processed vertices
  #     b) D[bot] = D[top] = the last vertex added to D
  # 
  #     // Test if V[i] is inside D (as a polygon)
  #     If V[i] is left of D[bot]D[bot+1] and D[top-1]D[top]
  #         Skip V[i] and Continue with the next vertex
  # 
  #     // Get the tangent to the bottom
  #     While V[i] is right of D[bot]D[bot+1]
  #         Remove D[bot] from the bottom of D
  #     Insert V[i] at the bottom of D
  # 
  #     // Get the tangent to the top
  #     While V[i] is right of D[top-1]D[top]
  #         Pop D[top] from the top of D
  #     Push V[i] onto the top of D
  # }
  # 
  # Output: D = the ccw convex hull of W.

  def self.convex_hull(points)
    deque = initialize_deque(*points.slice!(0..2))
    
    while !points.empty?
      if current_point = point_inside_hull?(points.shift)
      end
    end
  end
  
  def self.initialize_deque(point_1, point_2, point_3)
    deque = [point_1, point_2, point_3]
    deque[1], deque[2] = deque[2], deque[1] if clockwise?(*deque)
    deque.insert(0, deque.last)
  end
  
  def self.point_inside_hull?(point, deque)
    point unless clockwise?(point, *deque[0..1]) && clockwise?(point, *deque[-2..-1])
  end

  def self.clockwise?(point_1, point_2, point_3)
    matrix = Matrix[
      [point_1.x.value, point_1.y.value, 1],
      [point_2.x.value, point_2.y.value, 1],
      [point_3.x.value, point_3.y.value, 1]
    ]
    
    matrix.determinant / 2.0 > 0
  end
end