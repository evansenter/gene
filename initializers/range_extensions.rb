class Range
  def min
    self.begin.is_a?(Float) ? self.begin : super
  end

  def max
    self.end.is_a?(Float) ? self.end : super
  end
end