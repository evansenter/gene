tests = Dir.new(File.dirname(__FILE__)).entries.select do |file_name|
  file_name =~ /^.*_test.rb$/
end
 
totals = { :tests => 0, :assertions => 0, :failures => 0, :errors => 0 }

tests.each do |test|
  print "Pulling in #{test}\n"
  
  results = `ruby #{test}`
  results =~ /(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors/
  
  totals[:tests]      += $1.to_i
  totals[:assertions] += $2.to_i
  totals[:failures]   += $3.to_i
  totals[:errors]     += $4.to_i 
  
  print "#{results}\n\n"
end

print "All tests have been run.\n\n"
print "Total results: #{totals[:tests]} tests, #{totals[:assertions]} assertions, #{totals[:failures]} failures, #{totals[:errors]} errors\n"