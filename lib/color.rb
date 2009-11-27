Color = Struct.new(:r, :g, :b, :a) do
  def rgb
    [r, g, b]
  end
  
  def rgba_format
    "rgba(" + (rgb.map(&:percentify) << a.value).join(", ") + ")"
  end
end