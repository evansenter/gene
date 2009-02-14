%w[chromosome].each do |file|
  require File.join("#{File.dirname(__FILE__)}", "#{file}.rb")
end

class Canvas
  attr_reader :chromosome
  
  def initialize(dimensions, num_polygons, num_zvertices)
    @chromosome = Chromosome.new(num_polygons)
  end
end