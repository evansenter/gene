require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class ImagineTest < Test::Unit::TestCase
  RGB = Struct.new(:red, :green, :blue)
  
  class TestClass
    include Imagine

    def image_dimensions
      Point.new(2, 2)
    end

    def each_pixel
      [
        [RGB.new(0, 0, 0), 0, 0],
        [RGB.new(0, 0, 0), 0, 1],
        [RGB.new(0, 0, 0), 1, 0],
        [RGB.new(0, 0, 0), 1, 1]
      ].each { |params| yield *params }
    end
  end
  
  def setup
    Magick.send(:remove_const, :MaxRGB)
    Magick.const_set(:MaxRGB, 1)
    
    @test_class = TestClass.new
    @test_class.stubs(:target_image).returns(@test_class)
  end
  
  def test_true
    assert true
  end
  
  def test_compare_image_to__identical_returns_1
    assert_in_delta 1.0, @test_class.compare_image_to(image_of_color(RGB.new(0, 0, 0))), 1e-5
  end
  
  def test_compare_image_to__opposite_returns_0
    assert_in_delta 0.0, @test_class.compare_image_to(image_of_color(RGB.new(1, 1, 1))), 1e-5
  end
  
  def test_compare_image_to__50_percent
    assert_in_delta 0.5, @test_class.compare_image_to(image_of_color(RGB.new(0.5, 0.5, 0.5))), 1e-5
  end
  
  private
  
  def image_of_color(color)
    returning(stub) do |image|
      2.times { |x| 2.times { |y| image.stubs(:pixel_color).with(x, y).returns(color) } }
    end
  end
end