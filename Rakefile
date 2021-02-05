require 'rake'
require 'rdoc/task'
require 'rake/clean'

CLEAN.include ['*.gem', 'pkg']

$spec = eval(File.read('overpass-doc.gemspec'))

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
    rdoc.main = "README.md"
end

task :package do
  sh %{gem build overpass-doc.gemspec}
end

task :install do
  sh %{sudo gem install --no-document overpass-doc-#{$spec.version}.gem}
end

desc "Uninstall the gem"
task :uninstall => [:clean] do
  sh %{sudo gem uninstall overpass-doc}
end
