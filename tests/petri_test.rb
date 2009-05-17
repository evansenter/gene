%w[test/unit rubygems mocha ../objects/petri.rb].each { |helper| require helper }

class PetriTest < Test::Unit::TestCase
  def test_true
    assert true
  end
end