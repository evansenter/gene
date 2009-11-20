require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class TestClass
  attr_accessor :chromosomes
  
  include Aligner
end

class AlignerTest < Test::Unit::TestCase
  def setup
    @test_class = TestClass.new
  end
  
  def test_true
    assert true
  end

  def test_align_crossover_for
    image_dimensions = Point.new(640, 480)
    
    chromosome_1_options = {
      :gene_0 => gene_options_with_points_at(Array.new(3, [0, 0])),
      :gene_1 => gene_options_with_points_at(Array.new(3, [10, 0])),
      :gene_2 => gene_options_with_points_at(Array.new(3, [20, 0]))
    }
    
    chromosome_2_options = {
      :gene_0 => gene_options_with_points_at(Array.new(3, [10, 0])),
      :gene_1 => gene_options_with_points_at(Array.new(3, [20, 0])),
      :gene_2 => gene_options_with_points_at(Array.new(3, [30, 0]))
    }
    
    @test_class.chromosomes = [
      Chromosome.new(3, 3, image_dimensions, chromosome_1_options),
      Chromosome.new(3, 3, image_dimensions, chromosome_2_options)
    ]

    optimal_alignment = @test_class.align_crossover
    
    assert_equal [0, 1, 2], optimal_alignment[:chromosome_1]
    assert_equal [1, 0, 2], optimal_alignment[:chromosome_2]
  end
  
  def test_crossover_map
    image_dimensions = Point.new(640, 480)
    
    chromosome_1_options = {
      :gene_0 => gene_options_with_points_at(Array.new(3, [0, 0])),
      :gene_1 => gene_options_with_points_at(Array.new(3, [15, 0]))
    }
    
    chromosome_2_options = {
      :gene_0 => gene_options_with_points_at(Array.new(3, [10, 0])),
      :gene_1 => gene_options_with_points_at(Array.new(3, [22.5, 0]))
    }
    
    @test_class.chromosomes = [
      Chromosome.new(2, 3, image_dimensions, chromosome_1_options),
      Chromosome.new(2, 3, image_dimensions, chromosome_2_options)
    ]

    assert_equal [[10, 22.5], [5, 7.5]], @test_class.send(:crossover_map)
  end
  
  def test_middle_point_of
    image_dimensions = Point.new(640, 480)
    gene_options     = gene_options_with_points_at([[0, 0], [30, 0], [0, 15], [30, 15]])
    middle_point     = @test_class.send(:middle_point_of, (Gene.new(4, image_dimensions, gene_options)))
    
    assert_equal 15, middle_point.x
    assert_equal 7.5, middle_point.y
  end
  
  def test_distance_between
    point_1 = Point.new(0, 0)
    point_2 = Point.new(3, 4)
    
    assert_equal 5, @test_class.send(:distance_between, point_1, point_2)
  end
  
  protected
  
  def gene_options_with_points_at(list)
    returning({}) do |gene_options|
      list.each_with_index do |tuple, index|
        gene_options[:"trait_x_#{index}"] = { :default => tuple.first }
        gene_options[:"trait_y_#{index}"] = { :default => tuple.last }
      end
    end
  end
end