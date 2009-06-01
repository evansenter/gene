desc "Runs the test suite"
task :run_tests do  
  totals = { :tests => 0, :assertions => 0, :failures => 0, :errors => 0 }

  FileList["./test/**/*_test.rb"].map { |path| path.gsub("test/", "") }.each do |test|
    results = `ruby -C test/ #{test}`
    results =~ /(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors/
  
    totals[:tests]      += $1.to_i
    totals[:assertions] += $2.to_i
    totals[:failures]   += $3.to_i
    totals[:errors]     += $4.to_i 
  
    print "#{results}\n"
  end

  print "Total results: #{totals[:tests]} tests, #{totals[:assertions]} assertions, #{totals[:failures]} failures, #{totals[:errors]} errors\n\n"
  print "Your tests are #{totals[:failures].zero? && totals[:errors].zero? ? 'PASSING' : 'FAILING'}.\n"
end

desc "Use rsync to copy updates from the codebase to the gem"
task :update_gem do
  sh "rsync -avz ./lib/* ./gem/gene/lib"
  sh "rsync -avz ./test/**_test.rb ./gem/gene/test"
end