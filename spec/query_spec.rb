RSpec.describe OverpassDoc::Query do

  let (:path)           { "/path/to/query "}
  let (:simple_query_txt)      { "node({{bbox}}); out geom;"}

  it "provides expected default values" do
    query = OverpassDoc::Query.new(path, simple_query_txt)
    expect( query.title ).to eq path
    expect( query.description ).to eql ""
    expect( query.tags ).to eql []
    expect( query.author ).to eql []

    expect( query.query ).to eql simple_query_txt
    expect( query.raw_query ).to eql simple_query_txt
    expect( query.query_string ).to eql("node%28%7B%7Bbbox%7D%7D%29%3B+out+geom%3B")
  end

  context "when parsing annotations" do
    let (:query ) {
      <<-QUERY
  /*
  This query looks for nodes, ways and relations
  with the given key/value combination.
  Choose your region and hit the Run button above!

  @title Find nodes, ways and relations in area
  @author Leigh Dodds
  @see a link
  @tags foo
  @tags bar

  */
  [out:json][timeout:25];
  // gather results
  (
    // query part for: “place=city”
    node["place"="city"]({{bbox}});
    way["place"="city"]({{bbox}});
    relation["place"="city"]({{bbox}});
  );
  // print results
  out body;
  >;
  out skel qt;
  QUERY
    }

    let(:parsed) { OverpassDoc::Query.new(path, query) }

    it "parses annotations" do
      expect(parsed.extract_annotation("")).to be_nil
      expect(parsed.extract_annotation("@name foo")).to eql(["name", "foo"])
    end

    it "parses title" do
      expect(parsed.title).to eql("Find nodes, ways and relations in area")
    end

    it "parses tags" do
      expect(parsed.tags).to eql(["foo", "bar"])
    end

    it "parses see" do
      expect(parsed.see).to eql(["a link"])
    end

    it "parses author" do
      expect(parsed.author).to eql(["Leigh Dodds"])
    end

    it "parses description" do
      expect(parsed.description).to match("This query looks for nodes, ways and relations")
    end

  end

end
