class Color
  attr_reader :r, :g, :b, :a
  
  def initialize(r, g, b, a)
    @r, @g, @b, @a = r, g, b, a
  end
  
  def to_hash
    { :r => @r, :g => @g, :b => @b, :a => @a }
  end
end