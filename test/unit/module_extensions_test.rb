require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class ModuleExtensionsTest < Test::Unit::TestCase
  def test_true
    assert true
  end
  
  def test_module__array_get
    assert_equal "#<UnboundMethod: String#reverse>", String[:reverse].inspect
  end
  
  def test_module__array_set
    String[:backwards] = lambda { reverse }
    assert_equal "syawedis", "sideways".backwards
  end
  
  def test_alias_method_chain
    def method; :old_method; end
    def method_with_chain; :chained_method; end
    
    class << self
      alias_method_chain :method, :chain
    end
    
    assert_equal :chained_method, method
    assert_equal :old_method, method_without_chain
  end
  
  def test_alias_method_chain__bang!
    def method!; :old_method; end
    def method_with_chain!; :chained_method; end
    
    class << self
      alias_method_chain :method!, :chain
    end
    
    assert_equal :chained_method, method!
    assert_equal :old_method, method_without_chain!
  end
end