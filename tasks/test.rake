desc "Runs the test suite"
task :test do  
  require "benchmark"
  
  totals = { :tests => 0, :assertions => 0, :failures => 0, :errors => 0 }
  Benchmark.measure do

    FileList["./test/**/*_test.rb"].map { |path| path.gsub("test/", "") }.each do |test|
      results = `ruby -C test/ #{test}`
      results =~ /(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors/
  
      totals[:tests]      += $1.to_i
      totals[:assertions] += $2.to_i
      totals[:failures]   += $3.to_i
      totals[:errors]     += $4.to_i 
  
      print "#{results}\n"
    end
  end.real.to_s.match(/(\d+\.\d{2})/)

  print "Total results: #{totals[:tests]} tests run in #{$1} seconds: #{totals[:assertions]} assertions, #{totals[:failures]} failures, #{totals[:errors]} errors\n\n"
  print "Your tests are #{totals[:failures].zero? && totals[:errors].zero? ? 'PASSING' : 'FAILING'}.\n"
end