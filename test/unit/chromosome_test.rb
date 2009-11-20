require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class ChromosomeTest < Test::Unit::TestCase
  def setup
    @num_genes        = 100
    @num_points       = 10
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
  
  def test_initialize__fitness_implicitly_set_to_default
    assert_equal Chromosome::DEFAULT_FITNESS, @chromosome.fitness
  end
  
  def test_initialize__fitness_explicitly_set
    chromosome = Chromosome.new(@num_genes, @num_points, @image_dimensions, :fitness => 0.75)
    
    assert_equal 0.75, chromosome.fitness
  end
  
  def test_initialize__no_options_should_pass_through_an_empty_hash_to_gene_initialize
    Gene.expects(:new).times(@num_genes).with(@num_points, @image_dimensions, {})
    
    Chromosome.new(@num_genes, @num_points, @image_dimensions)
  end
  
  def test_get_parameters
    assert_equal [100, 10, @image_dimensions], @chromosome.get_parameters
  end
  
  def test_genes_by_alpha
    gene_options = returning({}) do |hash|
      hash[:gene_0] = options_for_gene(:trait_a => { :default => 0.5 })
      hash[:gene_1] = options_for_gene(:trait_a => { :default => 0.0 })
      hash[:gene_2] = options_for_gene(:trait_a => { :default => 1.0 })
    end

    chromosome = Chromosome.new(3, 3, @image_dimensions, gene_options)
    
    assert_equal [0.5, 0.0, 1.0], chromosome.genes.map(&:color).map(&:a).map(&:value)    
    assert_equal [1.0, 0.5, 0.0], chromosome.genes_by_alpha.map(&:color).map(&:a).map(&:value)
  end
  
  def test_genes_from_alignment_map
    chromosome = Chromosome.new(3, 3, @image_dimensions)
  
    assert_equal [chromosome.genes[2], chromosome.genes[0], chromosome.genes[1]], chromosome.genes_from_alignment_map([2, 0, 1])
  end
  
  private
  
  def options_for_gene(options = {})
    options = {
      :trait_x_0 => { :default => 1 },
      :trait_y_0 => { :default => 1 },
                      
      :trait_x_1 => { :default => 100 },
      :trait_y_1 => { :default => 100 },
                      
      :trait_x_2 => { :default => 200 },
      :trait_y_2 => { :default => 200 },
                      
      :trait_r   => { :default => 50 },
      :trait_g   => { :default => 150 }, 
      :trait_b   => { :default => 250 },
      :trait_a   => { :default => 0.5 }
    }.merge(options)
  end
  
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