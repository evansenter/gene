# Get all source files except this one, pulling initializers before the lib_files.
initializers = Dir.glob(File.join(File.dirname(__FILE__), "**", "*.rb")) - [__FILE__]
lib_files    = Dir.glob(File.join(File.dirname(__FILE__), "..", "lib", "**", "*.rb"))

# Set dynamic autoload on all of them based on their filename.
constants = (initializers + lib_files).inject([]) do |constants, file_path|  
  constant = File.basename(file_path, ".rb").split(/_/).map(&:capitalize).join.to_sym
  autoload(constant, file_path)
end

# Pull in the initializer files!
initializers.map(&method(:require))