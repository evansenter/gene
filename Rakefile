require "rubygems"
require "rake"
require "echoe"

Echoe.new("gene", "0.1.0") do |config|
  config.description              = "Sample genetic program in Ruby"
  config.url                      = "http://github.com/evansenter/gene"
  config.author                   = "Evan Senter"
  config.email                    = "evansenter@gmail.com"
  config.ignore_pattern           = ["tmp/*", "script/*"]
  config.dependencies             = ["rmagick"]
  config.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |task| load task }