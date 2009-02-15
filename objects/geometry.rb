%w[extensions].each do |file|
  require File.join("#{File.dirname(__FILE__)}", "#{file}.rb")
end

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
end