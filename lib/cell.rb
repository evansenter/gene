class Cell < Dsl  
  attr_accessor :fitness
  attr_reader   :genes, :image
  
  def genes_by_alpha
    genes.sort { |gene_1, gene_2| gene_2.color.a.value <=> gene_1.color.a.value }
  end
  
  def genes_from_alignment_map(alignment)
    alignment.map { |index| genes[index] }
  end
  
  private
  
  def finish_init
    fill_out_genes
    draw_image
  end
  
  def fill_out_genes
    @genes = num_genes.times.map { |index| (@genes ||= [])[index] || Gene.new }
  end
  
  def draw_image
    @image = Magick::Image.new(image_dimensions.x, image_dimensions.y)
    pen    = Magick::Draw.new
  
    genes_by_alpha.each do |gene|
      pen.fill(gene.color.rgba_format)
      pen.polygon(*gene.hulled_sequence)
      pen.draw(@image)
    end
  end
  
  def method_missing(name, *args, &block)
    case name.to_s
    when /^gene_(\d+)$/: (@genes ||= [])[$1.to_i] = Gene.new(&block)
    else super
    end
  end
end