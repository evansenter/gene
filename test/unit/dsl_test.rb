require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

class TestClass
  include Dsl
  
  def initialize
    @set_in_init = true
  end
  
  def finish_init
    @set_in_finish_init = true
  end
  
  def method_missing(name, *args, &block)
    if name == :test_method_missing
      @set_in_block_method_missing = true
    end
    :_super
  end
end

class CalculatorTest < Test::Unit::TestCase
  def setup
    @test_class = TestClass.new do
      @set_in_block = true
      test_method_missing
    end
  end
  
  def test_true
    assert true
  end
  
  def test_dsl__self_changed_in_block
    %w[init finish_init block block_method_missing].each do |suffix|
      assert @test_class.instance_variable_get(:"@set_in_#{suffix}"), suffix
    end
    
    assert_raise NoMethodError do
      TestClass.new { rawr! }
    end
  end
  
  def test_method_missing__lookup_in_binding_self
    assert instance_variable_get(:@set_in_binding_method_missing)
  end
  
  private
  
  def method_missing(name, *args, &block)
    if name == :test_method_missing
      @set_in_binding_method_missing = true
    else
      super
    end
  end
end