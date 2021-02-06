RSpec.describe OverpassDoc::Query do

  let (:path)       { "/path/to/query "}
  let (:query_txt)      { "node({{bbox}}); out geom;"}

  it "provides expected default values" do
    query = OverpassDoc::Query.new(path, query_txt)
    expect( query.title ).to eq path
    expect( query.description ).to eql ""
    expect( query.tag ).to eql []
    expect( query.author ).to eql []

    expect( query.query ).to eql query_txt
    expect( query.raw_query ).to eql query_txt
    expect( query.query_string ).to eql("node%28%7B%7Bbbox%7D%7D%29%3B+out+geom%3B")
  end

end
