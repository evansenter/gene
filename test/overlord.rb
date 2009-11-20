# Run the tests! All of them!
Dir.glob(File.join(File.dirname(__FILE__), "..", "test", "*_test.rb")).each { |test_file| print `ruby #{test_file}` }