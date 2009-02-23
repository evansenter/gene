require "test/unit"
require "rubygems"
require "mocha"
require "../objects/hungarian.rb"

class TraitTest < Test::Unit::TestCase
  def test_true
    assert true
  end

  def test_minimize_rows
    hungarian = Hungarian.new([[1, 2, 3], [1, 0, 1], [2, 2, 2]])
    expected = [[0, 1, 2], [1, 0, 1], [0, 0, 0]]
    assert_equal expected, hungarian.send(:minimize_rows)
  end
end