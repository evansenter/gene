require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class TestClass
  attr_accessor :chromosomes
  
  include Aligner
end

class AlignerTest < Test::Unit::TestCase
  def setup
    @test_class       = TestClass.new
    @image_dimensions = Point.new(640, 480)
  end
  
  def test_true
    assert true
  end

  def test_align_crossover_for
    @test_class.chromosomes = [
      Chromosome.new(3, 3, @image_dimensions) do
        gene_0 &three_points_at(0, 0)
        gene_1 &three_points_at(10, 0)
        gene_2 &three_points_at(20, 0)
      end,
      Chromosome.new(3, 3, @image_dimensions) do
        gene_0 &three_points_at(10, 0)
        gene_1 &three_points_at(20, 0)
        gene_2 &three_points_at(30, 0)
      end
    ]

    optimal_alignment = @test_class.align_crossover
    
    assert_equal [0, 1, 2], optimal_alignment[:chromosome_1]
    assert_equal [1, 0, 2], optimal_alignment[:chromosome_2]
  end
  
  def test_crossover_map
    @test_class.chromosomes = [
      Chromosome.new(2, 3, @image_dimensions) do
        gene_0 &three_points_at(0, 0)
        gene_1 &three_points_at(15, 0)
      end,
      Chromosome.new(2, 3, @image_dimensions) do
        gene_0 &three_points_at(10, 0)
        gene_1 &three_points_at(22.5, 0)
      end
    ]

    assert_equal [[10, 22.5], [5, 7.5]], @test_class.send(:crossover_map)
  end
  
  def test_middle_point_of
    gene = Gene.new(4, @image_dimensions) do
      point_0 0, 0
      point_1 30, 0
      point_2 0, 15
      point_3 30, 15
    end
    
    middle_point = @test_class.send(:middle_point_of, gene)
    
    assert_equal 15, middle_point.x
    assert_equal 7.5, middle_point.y
  end
  
  def test_distance_between
    point_1 = Point.new(0, 0)
    point_2 = Point.new(3, 4)
    
    assert_equal 5, @test_class.send(:distance_between, point_1, point_2)
  end
  
  protected
  
  def three_points_at(x, y)
    lambda do
      point_0 x, y
      point_1 x, y
      point_2 x, y
    end
  end
end