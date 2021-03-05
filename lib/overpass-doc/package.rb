require "pathname"

module OverpassDoc
  #A directory containing a package.json, query files and supporting assets
  class Package
    include Helpers

    attr_reader :dir, :metadata, :queries, :children, :generator

    def initialize(generator, src_dir, parent=nil)
      @dir = src_dir
      @generator = generator
      @parent = parent
      @metadata = parse_metadata()
      @queries = parse_queries()
      @children = parse_nested_packages()
    end

    def child?
      @parent != nil
    end

    #available in template
    def title
      @metadata["title"] || "Overpass Query Documentation"
    end

    def description
      @metadata["description"] || ""
    end

    def path
      File.path(@dir).dup.gsub(@generator.dir, "")
    end

    def parent
      @parent
    end

    def generate
      generate_index
      generate_query_pages
      copy_extra_files
      @children.each do |child|
        child.generate
      end
    end

    private

    def parse_metadata()
      package = File.join(@dir, "package.json")
      if File.exists?(package)
        return JSON.load( File.open(package) )
      end
      Hash.new
    end

    def parse_queries
      queries = []
      Dir.glob("#{@dir}/*.osm") do |file|
        content = File.read(file)
        path = file.gsub("#{@dir}/", "")
        queries << OverpassDoc::Query.new(path, content, @metadata)
      end
      queries.sort! {|x,y| x.title <=> y.title }
      queries
    end

    def parse_nested_packages
      children = []
      dirs = Pathname.new(@dir).children.select { |c| c.directory? }.collect { |p| p.to_s }
      dirs.each do |dir|

        children << OverpassDoc::Package.new(@generator, dir, self) if !dir.include?(".git")
      end
      children
    end

    def copy_extra_files
      @metadata["extra-files"]["files"].each do |file|
        markup = File.read( File.join(@dir, file["file"]) )
        _content = render_markdown(markup)
        template = ERB.new( @generator.read_template(:extra) )
        html = layout do
          b = binding
          template.result(b)
        end
        filename = file["file"].gsub(".md", ".html")
        @generator.write_file(self, filename, html)
      end if @metadata["extra-files"]
    end

    #available in template
    def overview
      return @overview if @overview
      overview = File.join(@dir, "overview.md")
      if File.exists?( overview )
        markup = File.read( overview )
        @overview = render_markdown(markup)
        return @overview
      end
      nil
    end

    def generate_index
      $stderr.puts("Generating index.html")
      @generator.write_file(self, "index.html", render_with_layout(:index))
    end

    def render_markdown(src)
      renderer = Redcarpet::Render::HTML.new({})
      markdown = Redcarpet::Markdown.new(renderer, {})
      markdown.render(src)
    end

    def render_with_layout(template, variables={})
      template = ERB.new( @generator.read_template(template) )
      b = binding
      variables.each do |key, value|
        b.local_variable_set(key, value)
      end
      html = layout(variables) do
        template.result(b)
      end
      return html
    end

    def layout(variables=nil)
      b = binding
      variables.each do |key, value|
        b.local_variable_set(key, value)
      end if variables
      ERB.new( @generator.read_template(:layout) ).result(b)
    end

    def generate_query_pages
      @queries.each do |query|
        $stderr.puts("Generating docs for #{query.path}")
        html = render_with_layout(:query, {query: query})
        @generator.write_file(self, query.path, query.raw_query)
        @generator.write_file(self, query.output_filename, html)
      end
    end

  end
end
