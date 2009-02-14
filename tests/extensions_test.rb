require "test/unit"
require "rubygems"
require "mocha"
require "../objects/extensions.rb"

class ExtensionsTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_returning
    return_value = returning(1) { nil }
    assert_equal 1, return_value
  end
end