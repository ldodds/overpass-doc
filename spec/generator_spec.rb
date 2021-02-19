RSpec.describe OverpassDoc::Generator, fakefs: true do
  before(:each) do
    FakeFS.activate!
    FileUtils.mkdir_p("/lib/views")
    FileUtils.touch("/lib/views/index.erb")
    FileUtils.touch("/lib/views/query.erb")
    FileUtils.touch("/lib/views/layout.erb")

    FileUtils.mkdir_p("/lib/assets")
    FileUtils.touch("/lib/assets/test.js")
    FileUtils.touch("/lib/assets/test.css")

    FileUtils.mkdir_p("/lib/assets/nested")
    FileUtils.mkdir_p("/lib/assets/nested/nested.js")

    FileUtils.mkdir_p("/in")

    File.open("/in/test.op", "w") do |f|
      f.puts "node({{bbox}}); out geom;"
    end
  end

  after(:each) do
    FakeFS.deactivate!
  end

  it "copies assets" do
    generator = OverpassDoc::Generator.new("/in", "/out", "/lib/views", "/lib/assets")
    generator.copy_assets()
    expect( File.exists?("/out/test.js") ).to eql(true)
    expect( File.exists?("/out/test.css") ).to eql(true)
    expect( File.exists?("/out/nested/nested.js") ).to eql(true)
  end

  it "parses and renders overview" do
    File.open("/lib/views/layout.erb", "w") do |f|
      f.puts "<%= overview %>"
    end

    File.open("/in/overview.md", "w") do |f|
      f.puts "Overview"
    end
    generator = OverpassDoc::Generator.new("/in", "/out", "/lib/views", "/lib/assets")
    generator.run
    expect( File.exists?("/out/index.html") ).to eql(true)
    expect( File.read("/out/index.html") ).to match("<p>Overview</p>")
  end

end
