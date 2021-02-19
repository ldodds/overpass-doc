# Generate HTML documentation for OSM Overpass queries

`overpass-doc` provides a simple tool for generating browsable HTML documentation
from Overpass queries.

It's intended to support people in producing tutorials and training material
to help people learn how to query OpenStreetmap. It may also be helpful to local
communities or projects that regularly need to share and run queries. For example to
help monitor changes in their area, or identify mapping tasks.

## Documenting Overpass queries

`overpass-doc` supports markup for documenting Overpass QL queries, as well as a
package metadata for a collection of queries.

These features are described in the next sections.

### Overpass QL Documentation Extensions

`overpass-doc` processes your Overpass queries, saved as text files with a `.op` extension.

It then looks for a comment at the top of the query. Like Javadoc, rdoc and
similar tools, the content of those comments are used to provide metadata

All simple documentation lines at the start of a query will be treated as its description. E.g:

```
/*
This is a description
of my query. It has multiple
lines
*/
```

Special tag can be used to specify other metadata, such as the title of a query:

```
/*
This is a description
of my query. It has multiple
lines
@title This is the title
*/
```

The full list of supported tags is:

* `@title`: should have a single value. Last title tag wins
* `@author`: author(s) of the query.
* `@see`: add one or more links
* `@tags`: add a tag to a query. Multiple values

Here's an example that uses all these:

```
/*
Specifies a bounding box to query for glacier data in a specific area of
Switzerland.

@title Extract glacier features as a specific location
@author Leigh Dodds
@see https://en.wikipedia.org/wiki/Upper_Grindelwald_Glacier
@tags glacier
*/
[out:json][timeout:25][bbox:46.5914,8.0828,46.6301, 8.1674];
// gather results
(
  // query part for: “natural=glacier”
  node["natural"="glacier"];
  way["natural"="glacier"];
  relation["natural"="glacier"];
);
// print results
out body;
>;
out skel qt;
```

The query description can be written in [Markdown](http://daringfireball.net/projects/markdown/). So
you can include embedded markup, e.g. links, that help to further document a query.

### Overview Documentation

When processing a directory of queries, `overpass-doc` will automatically look for a file called
`overview.md`. If found, this file will be automatically parsed as Markdown and its contents included
in an Overview section on the homepage of the documentation.

While the `description` in the `package.json` file is intended to provide a one line summary of the
package, the `overview.md` file is intended to provide a more detailed introduction. Both are optional,
so authors can choose which approach they prefer.

### Package Metadata

`overpass-doc` considers a directory of queries to be a _package_. Metadata that describes a package
and how its documentation should be generated is provided by a valid JSON file called `package.json` which
is found in the same directory.

The following example of a package.json file shows how to provide a title and a short description
of a package of files. The title and description will automatically be injected into the documentation.

```
{
 "title": "Sample OSM Queries",
 "description": "A useful selection of queries for beginners"
}
```

It is common for a collection of queries to be written by the same person, be tagged in the same
way, or be useful against the same collection of endpoints. Rather than repeatedly apply the
`@author`, `@tags` and `@endpoint` annotations to all queries in a package, default values can be
specified in the `package.json` file.

The following example shows how to do this:

```
{
 "title": "Sample OSM Queries",
 "description": "A useful selection of queries for beginners"
 "author": ["Leigh Dodds"],
}
```

Note that because `@author`, `@tags` and `@see` are all multi-valued annotations, their values
must be specified as a JSON array.

The `package.json` file can also be used to indicate that extra files in the query directory should be
processed and included in the documentation. E.g.:

```
{
  "title": "Sample OSM Queries",
   "description": "A useful selection of queries for beginners"
 "extra-files": ["more-info.md"]
}
```

This will trigger `overpass-doc` to process the `more-info.md` file as Markdown, converting it to
`more-info.html` which is added to the output directory. A link to `more-info` will be automatically
added to the header navigation

## Example

Here's [some example output](https://ldodds.github.io/osm-queries/) using the example queries included in the project.

## Installation

`overpass-doc` is available as a gem:

	gem install overpass-doc

### Manual Install

You'll need to make sure you have the following installed:

* Ruby 2.5.0+
* RubyGems
* Bundler
* Rake

Once you have those installed, clone the repository and run the provided rake targets to build and install the gem
locally:

	git clone https://github.com/ldodds/overpass-doc.git
	cd overpass-doc

The code uses two gems which you'll need to have installed: JSON and [Redcarpet](https://github.com/vmg/redcarpet):

	bundle install

Once installed you should be able to run the `bin/overpass-doc` command-line tool.

## Usage

_Note: the command-line syntax is likely to change in future. E.g. to add more options and/or other commands_

This takes two parameters:

* The input directory. The tool will process all `.op` files in that directory
* The output directory. All HTML output and required assets will be placed here

The output directory is optional. If not specified it will create a directory called
`overpass-doc` in the current directory.

E.g. you can run:

	overpass-doc queries pages

This will generate documentation from the bundled examples and place it into the specified
directory.

## License

This work is hereby released into the Public Domain.

To view a copy of the public domain dedication, visit http://creativecommons.org/licenses/publicdomain or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
