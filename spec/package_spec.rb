module OverpassDoc
  describe Package do

    before(:each) do
      FakeFS.activate!
      FileUtils.mkdir_p("/in")
      File.open("/in/test.op", "w") do |f|
        f.puts "node({{bbox}}); out geom;"
      end
    end

    let(:generator) { OverpassDoc::Generator.new("/in", "/out", "/lib/views", "/lib/assets")}
    let(:package)   { OverpassDoc::Package.new(generator, "/in") }

    after(:each) do
      FakeFS.deactivate!
    end

    context "parsing package" do

      it "parses queries" do
        expect( package.queries.size ).to eql 1
      end

      it "parses package file" do
        expect( package.metadata ).to eql({})

        File.open("/in/package.json", "w") do |f|
          f.puts "{\"title\": \"Package Title\"}"
        end

        package = OverpassDoc::Package.new(generator, "/in")
        expect( package.metadata ).to eql({"title"=>"Package Title"})
      end

      it "parses child packages" do
        expect( package.children ).to eql([])

        FileUtils.mkdir_p("/in/nested")
        File.open("/in/nested/query.op", "w") do |f|
          f.puts "node({{bbox}}); out geom;"
        end
        package = OverpassDoc::Package.new(generator, "/in")
        expect( package.children.size ).to eql(1)
        expect( package.children.first.dir ).to eql("/in/nested")
      end
    end

    describe '#asset_path' do
      it "generates correct path" do
        expect( package.asset_path("file.js") ).to eql("file.js")

        package = OverpassDoc::Package.new(generator, "/in/nested")
        expect( package.asset_path("file.js") ).to eql("../file.js")

      end
    end
  end
end
