%w[test/unit rubygems mocha ../objects/chromosome.rb].each { |helper| require helper }

class TestClass
  include Calculator
end

class CalculatorTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_generate_value__raises_error_when_max_is_nil_or_zero
    assert_raise ArgumentError do 
      TestClass.generate_value(nil) 
    end
    
    assert_raise ArgumentError do 
      TestClass.generate_value(0) 
    end
  end
  
  def test_generate_value__returns_same_type_as_max    
    assert TestClass.generate_value(1.0).is_a?(Float)
    assert TestClass.generate_value(100).is_a?(Fixnum)
  end

  def test_get_normal_random_variable__x
    sum = mock
    sum.expects(:+).with(:y).returns(sum)
    sum.expects(:<).with(1).returns(true)
    
    x = mock
    x.expects(:**).with(2).returns(sum)
    y = mock
    y.expects(:**).with(2).returns(:y)
    
    TestClass.expects(:get_uniform_random_variable).twice.returns(x, y)
    TestClass.expects(:rand).with(2).returns(0)
    TestClass.expects(:convert).with(x, sum)
    
    TestClass.get_normal_random_variable
  end

  def test_get_normal_random_variable__y
    sum = mock
    sum.expects(:+).with(:y).returns(sum)
    sum.expects(:<).with(1).returns(true)
    
    x = mock
    x.expects(:**).with(2).returns(sum)
    y = mock
    y.expects(:**).with(2).returns(:y)
    
    TestClass.expects(:get_uniform_random_variable).twice.returns(x, y)
    TestClass.expects(:rand).with(2).returns(1)
    TestClass.expects(:convert).with(y, sum)
    
    TestClass.get_normal_random_variable
  end

  def test_get_normal_random_variable__loops_until_sum_is_less_than_one
    sum = mock
    sum.expects(:+).with(:y).returns(sum)
    sum.expects(:<).with(1).returns(true)
    
    x = mock
    x.expects(:**).with(2).returns(sum)
    y = mock
    y.expects(:**).with(2).returns(:y)
    
    TestClass.expects(:get_uniform_random_variable).times(4).returns(1, 1, x, y)
    TestClass.expects(:rand).with(2).returns(0)
    TestClass.expects(:convert).with(x, sum)
    
    TestClass.get_normal_random_variable
  end

  def test_get_uniform_random_variable
    random_value = mock
    random_value.expects(:*).with(:sign)
    TestClass.expects(:rand).with(0).returns(random_value)
    TestClass.expects(:random_sign_change).returns(:sign)
    
    TestClass.get_uniform_random_variable
  end
  
  def test_random_sign_change
    TestClass.expects(:rand).with(2).returns(0)
    assert_equal 1, TestClass.send(:random_sign_change)
    
    TestClass.expects(:rand).with(2).returns(1)
    assert_equal -1, TestClass.send(:random_sign_change)
  end
  
  def test_convert
    assert_equal 0, TestClass.send(:convert, 1, 0)
    assert_equal 0, TestClass.send(:convert, 0, 0)
    assert_equal 0, TestClass.send(:convert, 0, 1)
  end
end