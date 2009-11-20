# Run the tests! All of them!
Dir.glob(File.join(File.dirname(__FILE__), "..", "test", "*_test.rb")).each { |test_file| print `ruby #{test_file}` }

git add	initializers/                            &&   
git add	lib/calculator.rb                        &&   
git add	lib/geometry.rb                          &&   
git add	lib/hungarian.rb                         &&   
git add	scripts/gc_stats.rb                      &&   
git add	scripts/profiling_hungarian              &&   
git add	test/functionals_extensions_test.rb      &&   
git add	test/module_extensions_test.rb           &&   
git add	test/object_extensions_test.rb           &&   
git add	test/overlord.rb                         &&   
git add	test/range_extensions_test.rb            &&   
git add	test/symbol_extensions_test.rb           &&   
git add	test/test_helper.rb                      &&   
git add	test/unbound_method_extensions_test.rb        