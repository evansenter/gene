require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class ChromosomeTest < Test::Unit::TestCase
  def setup
    @num_genes        = 50
    @num_points       = 3
    @image_dimensions = Point.new(640, 480)
    @chromosome       = Chromosome.new(@num_genes, @num_points, @image_dimensions)
  end
  
  def test_true
    assert true
  end

  def test_initialize
    image_range_x = (0...@image_dimensions.x)
    image_range_y = (0...@image_dimensions.y)
    color_range   = (0...256)
    alpha_range   = (0.0..1.0)    

    @chromosome.genes.each do |gene|      
      assert_equal @num_points, gene.polygon.num_points
      
      assert gene.polygon.points.all? { |point| image_range_x.include?(point.x.value) && image_range_y.include?(point.y.value) }
      assert gene.color.rgb.all? { |vector| color_range.include?(vector.value) }
      assert alpha_range.include?(gene.color.a.value)
    end
  end
  
  def test_initialize__with_block
    chromosome = Chromosome.new(@num_genes, @num_points, @image_dimensions) do
      set_fitness 1
    end
    
    lambda { |index| assert chromosome.genes[index].is_a?(Gene) } | chromosome.num_genes.times
    assert_equal 1, chromosome.fitness
    
    assert_raise NoMethodError do
      Chromosome.new(@num_genes, @num_points, @image_dimensions) { rawr! }
    end
  end
  
  def test_initialize__fitness_implicitly_set_to_default
    assert_equal Chromosome::DEFAULT_FITNESS, @chromosome.fitness
  end
  
  def test_initialize__fitness_explicitly_set
    chromosome = Chromosome.new(@num_genes, @num_points, @image_dimensions) { set_fitness 0.75 }
    
    assert_equal 0.75, chromosome.fitness
  end
  
  def test_get_parameters
    assert_equal [50, 3, @image_dimensions], @chromosome.get_parameters
  end
  
  def test_genes_by_alpha
    chromosome = Chromosome.new(3, 3, @image_dimensions) do
      gene_0 do
        trait_a do
          set_value 0.5
        end
      end
      gene_1 do
        trait_a do
          set_value 0.0
        end
      end
      gene_2 do
        trait_a do
          set_value 1.0
        end
      end
    end
    
    assert_equal [0.5, 0.0, 1.0], chromosome.genes.map(&:color).map(&:a).map(&:value)    
    assert_equal [1.0, 0.5, 0.0], chromosome.genes_by_alpha.map(&:color).map(&:a).map(&:value)
  end
  
  def test_genes_from_alignment_map
    chromosome = Chromosome.new(3, 3, @image_dimensions)
  
    assert_equal [chromosome.genes[2], chromosome.genes[0], chromosome.genes[1]], chromosome.genes_from_alignment_map([2, 0, 1])
  end
  
  private
  
  def mutation_distribution_helper
    trait = Trait.new(:x, (0..255), { :default => 10, :standard_deviation => 0.25 })
    distribution = trait.range.map { 0.0 }
    
    1000.times do
      value = Chromosome.mutate(trait, 0.25)
      distribution[value] += 1
    end
    
    sum = lambda { |a, b| a + b } <= distribution
    p distribution.map { |value| value / sum * 100 }
  end
end