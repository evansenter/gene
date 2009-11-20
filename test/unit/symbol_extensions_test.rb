require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class SymbolExtensionsTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_symbol__array_get
    dashes = :*["-"]
    assert_equal "----------", dashes[10]
  end
  
  def test_symbol__array_set
    string = "Hello world."
    :singleton[string] = lambda { "You have found my singleton method." }
    assert_equal "You have found my singleton method.", string.singleton
  end
end