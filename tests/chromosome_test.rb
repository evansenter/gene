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
  
  def test_initialize__no_gene_options_passes_through_an_empty_hash
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
end