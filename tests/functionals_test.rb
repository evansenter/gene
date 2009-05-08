%w[test/unit rubygems mocha ../objects/extensions/functionals.rb].each { |helper| require helper }

class FunctionalsTest < Test::Unit::TestCase
  
  def test_true
    assert true
  end
  
  def test_apply
    sum = lambda { |x, y| x + y }
    
    assert_equal [3, 7], sum | [[1, 2], [3, 4]]
    assert_equal [3, 7], sum.apply([[1, 2], [3, 4]])
  end

  def test_reduce
    sum = lambda { |x, y| x + y }
    
    assert_equal 10, sum <= [1, 2, 3, 4]
    assert_equal 10, sum.reduce([1, 2, 3, 4])
  end
  
  def test_compose
    add_1  = lambda { |x| x + 1 }
    double = lambda { |x| x * 2 }
    
    assert_equal 5, (add_1 * double)[2]
    assert_equal 5, (add_1.compose(double))[2]
    
    assert_equal 6, (double * add_1)[2]
    assert_equal 6, (double.compose(add_1))[2]
  end
  
  
  def test_apply_head
    function = lambda { |x, y, z| x * y + z }
    assert_equal 24, (function >> 5)[4, 4]
  end
  
  def test_apply_tail
    function = lambda { |x, y, z| x * y + z }
    assert_equal 21, (function << 5)[4, 4]
  end
  
  def test_memoize
    factorial = +lambda { |x| x == 1 ? 1 : x * factorial[x - 1] }
    assert_equal 120, factorial[5]
    
    factorial = lambda { |x| x == 1 ? 1 : x * factorial[x - 1] }.memoize
    assert_equal 120, factorial[5]
  end
end