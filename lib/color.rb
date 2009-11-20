Color = Struct.new(:r, :g, :b, :a) do
  def to_hash
    each_pair.inject({}) do |hash, key_value|
      attr, value = key_value
      returning(hash) { |hash| hash[attr] = value }      
    end
  end
end