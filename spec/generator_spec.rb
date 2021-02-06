RSpec.describe OverpassDoc::Generator, fakefs: true do
  before(:each) do
    FakeFS.activate!
    FileUtils.mkdir_p("/lib/views")
    FileUtils.touch("/lib/views/index.erb")
    FileUtils.touch("/lib/views/query.erb")

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

  it "parses queries" do
    generator = OverpassDoc::Generator.new("/in", "/out", "/lib/views", "/lib/assets")
    generator.parse_queries
    expect( generator.queries.size ).to eql 1
  end

  it "parses package file" do
    generator = OverpassDoc::Generator.new("/in", "/out", "/lib/views", "/lib/assets")
    expect( generator.parse_package ).to eql({})

    File.open("/in/package.json", "w") do |f|
      f.puts "{\"title\": \"Package Title\"}"
    end

    expect( generator.parse_package ).to eql({"title"=>"Package Title"})
  end

  it "parses and renders overview" do
    generator = OverpassDoc::Generator.new("/in", "/out", "/lib/views", "/lib/assets")
    expect( generator.get_overview ).to eql(nil)

    File.open("/in/overview.md", "w") do |f|
      f.puts "Overview"
    end
    expect( generator.get_overview ).to eql("<p>Overview</p>\n")
  end

end
