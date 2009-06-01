desc "Use rsync to copy updates from the codebase to the gem"
task :update_gem do
  sh "rsync -avz ./lib/* ./gem/gene/lib"
  sh "rsync -avz ./test/**_test.rb ./gem/gene/test"
end