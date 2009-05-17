%w[test/unit rubygems mocha ../objects/extensions/geometry.rb ../objects/chromosome.rb].each { |helper| require helper }

class TestClass
  include Geometry
end

class GeometryTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_hull__less_than_three_points
    point_list = [[], [create_point(0, 0)], [create_point(0, 0), create_point(0, 0)]]
    
    point_list.each do |point_list|
      assert_raise ArgumentError do
        assert_equal point_list, TestClass.hull
      end
    end
  end
  
  def test_hull_simple_case
    point_list = [create_point(0, 0), create_point(50, 0), create_point(50, 50)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(TestClass.hull(point_list))
  end
  
  def test_hull__one_point_inside
    point_list = [create_point(0, 0), create_point(50, 0), create_point(50, 50), create_point(10, 5)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(TestClass.hull(point_list))
  end
  
  def test_hull__three_points_on_a_line
    point_list = [create_point(0, 0), create_point(25, 0), create_point(50, 0), create_point(50, 50)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(TestClass.hull(point_list))    
  end
  
  def test_hull__three_points_on_a_line_with_one_point_inside
    point_list = [create_point(0, 0), create_point(25, 0), create_point(50, 0), create_point(50, 50), create_point(10, 5)]
    assert_equal [[0, 0], [50, 50], [50, 0]], format_points_in(TestClass.hull(point_list))    
  end
  
  def test_align_crossover_for
    image_dimensions = Point.new(640, 480)
    
    chromosome_1_point_0 = [0, 0]
    chromosome_1_point_1 = [10, 0]
    chromosome_1_point_2 = [20, 0]
    
    chromosome_1_options = {
      :gene_0 => gene_options_with_points_at(Array.new(3, chromosome_1_point_0)),
      :gene_1 => gene_options_with_points_at(Array.new(3, chromosome_1_point_1)),
      :gene_2 => gene_options_with_points_at(Array.new(3, chromosome_1_point_2))
    }
    
    chromosome_2_point_0 = [10, 0]
    chromosome_2_point_1 = [20, 0]
    chromosome_2_point_2 = [30, 0]
    
    chromosome_2_options = {
      :gene_0 => gene_options_with_points_at(Array.new(3, chromosome_2_point_0)),
      :gene_1 => gene_options_with_points_at(Array.new(3, chromosome_2_point_1)),
      :gene_2 => gene_options_with_points_at(Array.new(3, chromosome_2_point_2))
    }
    
    chromosome_1 = Chromosome.new(3, 3, image_dimensions, chromosome_1_options)
    chromosome_2 = Chromosome.new(3, 3, image_dimensions, chromosome_2_options)

    optimal_alignment = TestClass.align_crossover_for(chromosome_1, chromosome_2)
    
    assert_equal [0, 1, 2], optimal_alignment[:chromosome_1]
    assert_equal [1, 0, 2], optimal_alignment[:chromosome_2]
  end
  
  def test_crossover_map_for
    image_dimensions = Point.new(640, 480)
    
    chromosome_1_point_0 = [0, 0]
    chromosome_1_point_1 = [15, 0]
    
    chromosome_1_options = {
      :gene_0 => gene_options_with_points_at(Array.new(3, chromosome_1_point_0)),
      :gene_1 => gene_options_with_points_at(Array.new(3, chromosome_1_point_1))
    }
    
    chromosome_2_point_0 = [10, 0]
    chromosome_2_point_1 = [22.5, 0]
    
    chromosome_2_options = {
      :gene_0 => gene_options_with_points_at(Array.new(3, chromosome_2_point_0)),
      :gene_1 => gene_options_with_points_at(Array.new(3, chromosome_2_point_1))
    }
    
    chromosome_1 = Chromosome.new(2, 3, image_dimensions, chromosome_1_options)
    chromosome_2 = Chromosome.new(2, 3, image_dimensions, chromosome_2_options)

    assert_equal [[10, 22.5], [5, 7.5]], TestClass.send(:crossover_map_for, chromosome_1, chromosome_2)
  end
  
  def test_middle_point_of
    image_dimensions = Point.new(640, 480)
    gene_options     = gene_options_with_points_at([[0, 0], [30, 0], [0, 15], [30, 15]])
    middle_point     = TestClass.send(:middle_point_of, Gene.new(4, image_dimensions, gene_options))
    
    assert_equal 15, middle_point.x
    assert_equal 7.5, middle_point.y
  end
  
  def test_distance_between
    point_1 = Point.new(0, 0)
    point_2 = Point.new(3, 4)
    
    assert_equal 5, TestClass.send(:distance_between, point_1, point_2)
  end
  
  protected
  
  def create_point(x, y)
    Point.new(
      Trait.new(:x, (0...100), :default => x),
      Trait.new(:y, (0...100), :default => y)
    )
  end
  
  def format_points_in(array)
    array.map { |point| [point.x.value, point.y.value] }
  end
  
  def gene_options_with_points_at(list)
    returning({}) do |gene_options|
      list.each_with_index do |tuple, index|
        gene_options[:"trait_x_#{index}"] = { :default => tuple.first }
        gene_options[:"trait_y_#{index}"] = { :default => tuple.last }
      end
    end
  end
end