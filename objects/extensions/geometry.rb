module Geometry
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def hull(points)
      unless points.length >= 3
        raise(ArgumentError, "Can not calculate the convex hull unless there are at least 3 points (#{points.size} #{points.size == 1 ? 'was' : 'were'} provided)")
      end

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
    
    def align_crossover_for(chromosome_1, chromosome_2)
      distance_map = crossover_map_for(chromosome_1, chromosome_2)
      optimal_alignment = Hungarian.new(distance_map).solve

      returning({}) do |alignment_hash|
        alignment_hash[:chromosome_1] = []
        alignment_hash[:chromosome_2] = []

        optimal_alignment.each do |tuple|
          alignment_hash[:chromosome_1] << tuple.first
          alignment_hash[:chromosome_2] << tuple.last
        end
      end
    end
    
    private
    
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
      lambda { |pivot| ((point_1.x.value - point_2.x.value) * (pivot.y.value - point_2.y.value)) - ((pivot.x.value - point_2.x.value) * (point_1.y.value - point_2.y.value)) }
    end

    def convex?(points, xor_boolean)
      (determinant_function(points[0], points[2])[points[1]] > 0) ^ xor_boolean
    end
    
    def crossover_map_for(chromosome_1, chromosome_2)
      chromosome_1.genes.map do |chromosome_1_gene|
        chromosome_2.genes.map do |chromosome_2_gene|
          distance_between(middle_point_of(chromosome_1_gene), middle_point_of(chromosome_2_gene))
        end
      end
    end

    def middle_point_of(gene)
      sum     = lambda { |a, b| a + b }
      average = lambda { |axis| (sum <= gene.polygon.points.map(&axis).map(&:value)) / gene.polygon.num_points.to_f }

      Point.new(average[:x], average[:y])
    end

    def distance_between(point_1, point_2)
      square = lambda { |value| value ** 2 }

      x_difference = point_2.x - point_1.x
      y_difference = point_2.y - point_1.y

      Math.sqrt(square[x_difference] + square[y_difference])
    end
  end
end