module Aligner
  def align_crossover
    optimal_alignment = Hungarian.new(crossover_map).solve

    returning({ :chromosome_1 => [], :chromosome_2 => [] }) do |alignment_hash|
      optimal_alignment.each do |tuple|
        alignment_hash[:chromosome_1] << tuple.first
        alignment_hash[:chromosome_2] << tuple.last
      end
    end
  end
  
  private
  
  def crossover_map
    @chromosomes.first.genes.map do |gene_1|
      @chromosomes.last.genes.map do |gene_2|
        distance_between(middle_point_of(gene_1), middle_point_of(gene_2))
      end
    end
  end

  def distance_between(point_1, point_2)
    square = lambda { |value| value ** 2 }
    Math.sqrt(square[point_2.x - point_1.x] + square[point_2.y - point_1.y])
  end

  def middle_point_of(gene)
    sum     = lambda { |a, b| a + b }
    average = lambda { |axis| (sum <= gene.polygon.points.map(&axis).map(&:value)) / gene.polygon.num_points.to_f }

    Point.new(average[:x], average[:y])
  end
end