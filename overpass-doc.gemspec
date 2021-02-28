PKG_FILES = %w( README.md Rakefile ) +
  Dir.glob("{bin,tests,lib}/**/*")

RDOC_OPTS = ['--quiet', '--title', 'Overpass QL Doc Reference', '--main', 'README']

Gem::Specification.new do |s|
  s.name = "overpass-doc"
  s.version = "0.0.4"
  s.licenses = "CC0-1.0"
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.5.0"
  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options = RDOC_OPTS
  s.summary = "Overpass documentation generator"
  s.description = "Generates HTML documentation for a collection of OSM Overpass queries"
  s.author = "Leigh Dodds"
  s.email = 'leigh@ldodds.com'
  s.homepage = 'http://github.com/ldodds/overpass-doc'
  s.files = PKG_FILES
  s.require_path = "lib"
  s.bindir = "bin"
  s.executables = ["overpass-doc"]
#  s.test_file = "tests/ts_sparql_doc.rb"
  s.add_dependency("json", "~> 2.5.1")
  s.add_dependency("redcarpet", "~> 3.5.1")
  s.add_development_dependency("fakefs", "~> 1.3.2")
  s.add_development_dependency("rspec", "~> 3.0")
end
