require File.join("#{File.dirname(__FILE__)}", "extensions/extensions.rb")

Color = Struct.new(:r, :g, :b, :a)

def Color.new(*args, &block)
  returning(object = allocate) do |color|
    color.send(:initialize, *args, &block)
    :to_hash[color] = lambda { { :r => r, :g => g, :b => b, :a => a } }
  end
end