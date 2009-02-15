%w[test/unit rubygems mocha ../objects/geometry.rb].each { |helper| require helper }

class GeometryTest < Test::Unit::TestCase
  def test_true
    assert true
  end
end