# You can pass a block to Struct.new to define instance methods on instantiated structs.
Color = Struct.new(:r, :g, :b, :a)

def Color.new(*args, &block)
  returning(object = allocate) do |color|
    color.send(:initialize, *args, &block)
    :to_hash[color] = lambda { { :r => r, :g => g, :b => b, :a => a } }
  end
end
