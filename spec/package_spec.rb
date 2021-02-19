module OverpassDoc
  describe Package do

    before(:each) do
      FakeFS.activate!
      FileUtils.mkdir_p("/in")

      File.open("/in/test.op", "w") do |f|
        f.puts "node({{bbox}}); out geom;"
      end
    end

    let(:package) { OverpassDoc::Package.new("/in") }

    after(:each) do
      FakeFS.deactivate!
    end

    it "parses queries" do
      expect( package.queries.size ).to eql 1
    end

    it "parses package file" do
      expect( package.metadata ).to eql({})

      File.open("/in/package.json", "w") do |f|
        f.puts "{\"title\": \"Package Title\"}"
      end

      package = OverpassDoc::Package.new("/in")
      expect( package.metadata ).to eql({"title"=>"Package Title"})
    end


  end
end
