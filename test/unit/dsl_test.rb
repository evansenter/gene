require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class TestClass < Dsl
  def initialize
    @set_in_init = true
    super
  end
  
  def finish_init
    @set_in_finish_init = true
  end
end

class DslTest < Test::Unit::TestCase
  def setup
    @test_class = TestClass.new do
      @set_in_block = true
      method_in_binding_scope
    end
  end
  
  def test_true
    assert true
  end
  
  def test_dsl__self_changed_in_block
    %w[init finish_init block].each do |suffix|
      assert @test_class.instance_variable_get(:"@set_in_#{suffix}")
    end
    
    assert_raise NoMethodError do
      TestClass.new { rawr! }
    end
  end
  
  def test_dsl__method_resolution_in_binding_scope
    assert @set_in_binding_scope
  end
  
  private
  
  def method_in_binding_scope
    @set_in_binding_scope = true
  end
end