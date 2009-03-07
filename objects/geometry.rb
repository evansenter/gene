require File.join("#{File.dirname(__FILE__)}", "extensions.rb")
require "matrix"

class Geometry
  def self.clockwise?(point_1, point_2, point_3)
    # Returns true if the points make a clockwise turn, and false if they are all on a line, or turn counter clockwise.
    area = Matrix[
      [point_1.x.value, point_1.y.value, 1],
      [point_2.x.value, point_2.y.value, 1],
      [point_3.x.value, point_3.y.value, 1]
    ].determinant / 2.0
    
    if area > 0
      :clockwise
    elsif area < 0
      :counterclockwise
    else
      :line
    end
  end
end