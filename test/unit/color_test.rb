require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class ColorTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_rgb
    color = Color.new(:r, :g, :b, :a)
    assert_equal [:r, :g, :b], color.rgb
  end
  
  def test_rgba_format
    color = Color.new(
      Trait.new(:value, 0.0..1.0) { set_value 0 },
      Trait.new(:value, 0.0..1.0) { set_value 0.25 },
      Trait.new(:value, 0.0..1.0) { set_value 0.5 },
      Trait.new(:value, 0.0..1.0) { set_value 0.75 }
    )
    
    assert_equal "rgba(0.0%, 25.0%, 50.0%, 0.75)", color.rgba_format
  end
end