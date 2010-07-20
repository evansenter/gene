# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gene}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Evan Senter"]
  s.date = %q{2010-07-20}
  s.description = %q{Sample genetic program in Ruby}
  s.email = %q{evansenter@gmail.com}
  s.extra_rdoc_files = ["TODO", "lib/aligner.rb", "lib/calculator.rb", "lib/cell.rb", "lib/color.rb", "lib/dsl.rb", "lib/gene.rb", "lib/generator.rb", "lib/geometry.rb", "lib/hungarian.rb", "lib/imagine.rb", "lib/petri.rb", "lib/point.rb", "lib/trait.rb", "tasks/test.rake"]
  s.files = ["Manifest", "Rakefile", "TODO", "initializers/functional_extensions.rb", "initializers/module_extensions.rb", "initializers/object_extensions.rb", "initializers/range_extensions.rb", "initializers/runner.rb", "initializers/symbol_extensions.rb", "initializers/unbound_method_extensions.rb", "lib/aligner.rb", "lib/calculator.rb", "lib/cell.rb", "lib/color.rb", "lib/dsl.rb", "lib/gene.rb", "lib/generator.rb", "lib/geometry.rb", "lib/hungarian.rb", "lib/imagine.rb", "lib/petri.rb", "lib/point.rb", "lib/trait.rb", "tasks/test.rake", "test/assets/Nova.jpg", "test/assets/Rex.jpg", "test/assets/Squares.jpg", "test/test_helper.rb", "test/unit/aligner_test.rb", "test/unit/calculator_test.rb", "test/unit/cell_test.rb", "test/unit/color_test.rb", "test/unit/dsl_test.rb", "test/unit/functionals_extensions_test.rb", "test/unit/gene_test.rb", "test/unit/generator_test.rb", "test/unit/geometry_test.rb", "test/unit/hungarian_test.rb", "test/unit/imagine_test.rb", "test/unit/module_extensions_test.rb", "test/unit/object_extensions_test.rb", "test/unit/petri_test.rb", "test/unit/range_extensions_test.rb", "test/unit/symbol_extensions_test.rb", "test/unit/trait_test.rb", "test/unit/unbound_method_extensions_test.rb", "gene.gemspec"]
  s.homepage = %q{http://github.com/evansenter/gene}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Gene"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gene}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Sample genetic program in Ruby}
  s.test_files = ["test/test_helper.rb", "test/unit/aligner_test.rb", "test/unit/calculator_test.rb", "test/unit/cell_test.rb", "test/unit/color_test.rb", "test/unit/dsl_test.rb", "test/unit/functionals_extensions_test.rb", "test/unit/gene_test.rb", "test/unit/generator_test.rb", "test/unit/geometry_test.rb", "test/unit/hungarian_test.rb", "test/unit/imagine_test.rb", "test/unit/module_extensions_test.rb", "test/unit/object_extensions_test.rb", "test/unit/petri_test.rb", "test/unit/range_extensions_test.rb", "test/unit/symbol_extensions_test.rb", "test/unit/trait_test.rb", "test/unit/unbound_method_extensions_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rmagick>, [">= 0"])
    else
      s.add_dependency(%q<rmagick>, [">= 0"])
    end
  else
    s.add_dependency(%q<rmagick>, [">= 0"])
  end
end
