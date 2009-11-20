require "test_helper"

class SymbolExtensionsTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_returning
    return_value = returning(1) { nil }
    assert_equal 1, return_value
  end
  
  def test_object__send_if
    assert_equal 3, [1, 2, 3].send_if(true, :length)
    assert_equal [1, 2, 3], [1, 2, 3].send_if(false, :length)
    
    assert_equal 1, [1, 2, 3].send_if(true, :[], 0)
    assert_equal [1, 2, 3], [1, 2, 3].send_if(false, :[], 0)
    
    assert_equal [2, 3, 4], [1, 2, 3].send_if(true, :map, proc { |element| element.succ })
    assert_equal [1, 2, 3], [1, 2, 3].send_if(false, :map, proc { |element| element.succ })
  end
  
  def test_assert_at_least__raises_error
    assert_raise ArgumentError do
      assert_at_least 3, 2
    end

    assert_nothing_raised do
      assert_at_least 3, 3
      assert_at_least 3, 4
    end
  end
end