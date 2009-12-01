module Imagine
  def compare_image_to(image)
    # http://en.wikipedia.org/wiki/RMSD
    aggregate_deviation = 0.0
    
    target_image.each_pixel do |target_pixel, x, y|      
      aggregate_deviation += compare_pixels(target_pixel, image.pixel_color(x, y))
    end
    
    1 - Math.sqrt(aggregate_deviation / (Magick::MaxRGB ** 2 * image_dimensions.x * image_dimensions.y * 3))
  end
  
  private
  
  def compare_pixels(target_pixel, actual_pixel)
    [:red, :green, :blue].inject(0.0) { |distance, channel| distance + compare_channel(channel, target_pixel, actual_pixel) }
  end
  
  def compare_channel(name, target_pixel, actual_pixel)
    (target_pixel.send(name) - actual_pixel.send(name)) ** 2
  end
end