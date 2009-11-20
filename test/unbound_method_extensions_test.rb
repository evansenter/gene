require "test_helper"

class UnboundMethodExtensionsTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_unbound_method__array_get
    assert_equal "syawedis", String[:reverse]["sideways"][]
  end
end