%w[test/unit rubygems mocha ../objects/extensions/extensions.rb].each { |helper| require helper }

class ExtensionsTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_returning
    return_value = returning(1) { nil }
    assert_equal 1, return_value
  end
  
  def test_add_bounding_methods_to__integer_range__max_and_min
    inclusive_range = (0..10)
    exclusive_range = (0...10)
    
    add_bounding_methods_to(inclusive_range)
    add_bounding_methods_to(exclusive_range)
    
    assert_equal 0,  inclusive_range.min
    assert_equal 10, inclusive_range.max

    assert_equal 0,  exclusive_range.min
    assert_equal 9,  exclusive_range.max
  end  
  
  def test_add_bounding_methods_to__float_range__max_and_min
    inclusive_range = (0.0..1.0)
    exclusive_range = (0.0...1.0)
    
    add_bounding_methods_to(inclusive_range)
    add_bounding_methods_to(exclusive_range)
    
    assert_equal 0.0, inclusive_range.min
    assert_equal 1.0, inclusive_range.max

    assert_equal 0.0, exclusive_range.min
    assert_equal 1.0, exclusive_range.max
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
  
  def test_symbol__to_proc
    arrays = [Array.new(0), Array.new(1), Array.new(2)]
    assert_equal [0, 1, 2], arrays.map(&:size)
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
  
  def test_module__array_get
    assert_equal "#<UnboundMethod: String#reverse>", String[:reverse].inspect
  end
  
  def test_module__array_set
    String[:backwards] = lambda { reverse }
    assert_equal "syawedis", "sideways".backwards
  end
  
  def test_unbound_method__array_get
    assert_equal "syawedis", String[:reverse]["sideways"][]
  end
end