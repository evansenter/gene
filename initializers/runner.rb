# Get all source files except this one, pulling initializers before the lib_files.
initializers = Dir.glob(File.join(File.dirname(__FILE__), "**", "*.rb")) - [__FILE__]
lib_files    = Dir.glob(File.join(File.dirname(__FILE__), "..", "lib", "**", "*.rb"))

# Set dynamic autoload on all of them based on their filename.
constants = (initializers + lib_files).inject([]) do |constants, file_path|  
  constant = File.basename(file_path, ".rb").split(/_/).map(&:capitalize).join.to_sym
  autoload(constant, file_path)
  constants << constant
end

# Pull in the files!
self.class.class_eval { constants.map(&method(:const_get)) }

# LONG NOTE: It may seem a little strange to autoload things the way I am, so I thought I'd provide some reasoning.
# The initializer files, in large part, mix methods into existing classes that are accessed implicitly (via inheritance).
# The autoload trick for pulling in files won't work in this case, because no constant (class reference) is provided to
# the interpreter for it to lookup and (in the case of autoload), pull in if not found. Rather, the interpreter assumes it already
# has everything it needs, and bombs when the method isn't found. For example:
#
# File a.rb - - - - -
# 
# class A
#   def say_hi
#     go_on_and_say_hi!
#   end
# end
# 
# A.new.go_on_and_say_hi!
# 
# File b.rb - - - - -
# 
# class Object
#   def go_on_and_say_hi!
#     puts "Fine, hello."
#   end
# end
#
# There's no way to implicitly pull in b.rb here from A, because we have no handle on a constant to be found in the file. This
# leaves us with two options. The first is to 'require' b.rb before a.rb is evaluated, but assuming we will be doing autoloading as
# well, we now have two different solutions in place, and that feels wrong - treating the inclusion of one directory differently than
# the other, just because it needs to be preloaded. The other option is to autoload everything. In this case, we're no longer 
# lazily loading files, but leveraging autoload to handle constant resolution for us. There is (at least) one wrinkle to this 
# solution. Module#autoload flips out if the file it's looking in doesn't define the constant it's looking for. Therefore if we are
# doing something like:
# 
# autoload(:B, "./b.rb")
# 
# File b.rb: I better god damn define B! - - - - -
# 
# module B; end
# 
# class Object
#   def go_on_and_say_hi!
#     puts "Fine, hello."
#   end
# end
# 
# Having that stray B definition on the top of the file looks pretty ugly to me, so why don't we do this instead?
# 
# autoload(:B, "./b.rb")
# 
# File b.rb: I better god damn define B! - - - - -
# 
# module B
#   ::Object.class_eval do
#     def go_on_and_say_hi!
#       puts "Fine, hello."
#     end
#   end
# end
# 
# And that's how this design came about. If you're reading this then you're either me (and you should rethink this design),
# or this is published somewhere, and you should tell me why I'm wrong. Here's some good starting points:
# 
# I'm polluting the global space with unused module shells.
# There is no semantic relationship from a module file to the code inside it.
# I'm killing baby otters by doing this.
# 
# There is still the requirement that initializers can't use IMPLICIT methods defined in initializer files not yet referenced, so they
# should be entirely self-contained. With this one caveat however, we've ensured that all files in ./lib have horizontal visibility
# and handles to everything defined in ./intializers