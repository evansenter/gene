%w[test/unit rubygems mocha ../objects/chromosome.rb].each { |helper| require helper }

class ChromosomeTest < Test::Unit::TestCase
  def test_true
    assert true
  end

  def test_initialize
    image_dimensions = Point.new(640, 480)
    num_genes, num_points = 100, 10
    chromosome = Chromosome.new(num_genes, num_points, image_dimensions)
    assert_equal num_genes, chromosome.num_genes

    chromosome.genes.each do |gene|      
      assert_equal num_points, gene.polygon.num_points
      
      gene.polygon.points.each do |point|
        assert((0...image_dimensions.x) === point.x.value)
        assert((0...image_dimensions.y) === point.y.value)
      end
      
      gene.color.rgb.each do |vector|
        assert((0...256) === vector.value)
      end
      
      assert(Range.new(0.0, 1.0) === gene.color.a.value)
    end
  end
  
  def test_initialize__no_options_should_pass_through_an_empty_hash_to_gene_initialize
    image_dimensions = Point.new(640, 480)
    num_genes, num_points = 100, 10
    Gene.expects(:new).times(num_genes).with(num_points, image_dimensions, {})
    
    Chromosome.new(num_genes, num_points, image_dimensions)
  end
  
  def test_get_parameters
    image_dimensions = Point.new(640, 480)
    chromosome = Chromosome.new(100, 10, image_dimensions)
    
    assert_equal [100, 10, image_dimensions], chromosome.get_parameters
  end
  
  def test_genes_from_alignment_map
    image_dimensions = Point.new(640, 480)
    chromosome = Chromosome.new(3, 3, image_dimensions)

    assert_equal [chromosome.genes[2], chromosome.genes[0], chromosome.genes[1]], chromosome.genes_from_alignment_map([2, 0, 1])
  end
  
  def test_genes_by_alpha
    image_dimensions = Point.new(640, 480)
    
    gene_options = returning({}) do |hash|
      hash[:gene_0] = options_for_gene(:trait_a => { :default => 0.5 })
      hash[:gene_1] = options_for_gene(:trait_a => { :default => 0.0 })
      hash[:gene_2] = options_for_gene(:trait_a => { :default => 1.0 })
    end

    chromosome = Chromosome.new(3, 3, image_dimensions, gene_options)
    
    assert_equal [0.5, 0.0, 1.0], chromosome.genes.map(&:color).map(&:a).map(&:value)    
    assert_equal [1.0, 0.5, 0.0], chromosome.genes_by_alpha.map(&:color).map(&:a).map(&:value)
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
end