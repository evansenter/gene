# require "rubygems"
# require "ruby-prof"
require "benchmark"
require "../lib/extensions/hungarian.rb"

hungarian = Hungarian.new
# hungarian_total_time = 0
# 
# 1000.times do
#   length = rand(50) + 1
#   
#   array  = (0...length).map { (0...length).map { rand(1000) } }
#   hungarian_solution = nil
#   
#   hungarian_runtime = Benchmark.measure { hungarian_solution = hungarian.solve(array) }
#   
#   hungarian_cost = hungarian_solution.inject(0) { |cost, index| cost += array[index[0]][index[1]] }
#   hungarian_total_time += hungarian_runtime.real
# 
#   print "Hungarian (#{length}): #{' ' if length < 10}#{hungarian_runtime}"
# end
# 
# print "Hungarian total time: #{hungarian_total_time}\n"

array = (0...100).map { (0...100).map { rand(1000) } }

# result = RubyProf.profile do
  # hungarian.solve(array)
# end

# printer = RubyProf::GraphPrinter.new(result)
# printer.print(STDOUT, 0)

gc_statistics { hungarian.solve(array) }