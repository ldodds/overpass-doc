module OverpassDoc
  #A directory containing a package.json, query files and supporting assets
  class Package
    attr_reader :dir, :queries, :metadata

    def initialize(src_dir)
      @dir = src_dir
      @metadata = parse_metadata()
      @queries = parse_queries()
    end

    def generate(generator)
      generate_index(generator)
      generate_query_pages(generator)
      copy_extra_files(generator)
    end

    private

    def parse_metadata()
      package = File.join(@dir, "package.json")
      if File.exists?(package)
        return JSON.load( File.open(package) )
      end
      Hash.new
    end

    def parse_queries()
      queries = []
      Dir.glob("#{@dir}/**/*.op") do |file|
        content = File.read(file)
        path = file.gsub("#{@dir}/", "")
        queries << OverpassDoc::Query.new(path, content, @metadata)
      end
      queries.sort! {|x,y| x.title <=> y.title }
      queries
    end

    def copy_extra_files(generator)
      @metadata["extra-files"].each do |file|
        markup = File.read( File.join(@dir, file) )
        _content = render_markdown(markup)
        template = ERB.new( generator.read_template(:extra) )
        html = layout(generator) do
          b = binding
          template.result(b)
        end
        filename = file.gsub(".md", ".html")
        generator.write_file(self, filename, html)
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

    def generate_index(generator)
      $stderr.puts("Generating index.html")
      generator.write_file(self, "index.html", render_with_layout(generator, :index))
    end

    def render_markdown(src)
      renderer = Redcarpet::Render::HTML.new({})
      markdown = Redcarpet::Markdown.new(renderer, {})
      markdown.render(src)
    end

    def render_with_layout(generator, template, variables={})
      template = ERB.new( generator.read_template(template) )
      b = binding
      variables.each do |key, value|
        b.local_variable_set(key, value)
      end
      html = layout(generator) do
        template.result(b)
      end
      return html
    end

    def layout(generator)
      b = binding
      ERB.new( generator.read_template(:layout) ).result(b)
    end

    #available in template
    def title
      @metadata["title"] || "Overpass Query Documentation"
    end

    def description
      @metadata["description"] || ""
    end

    def generate_query_pages(generator)
      @queries.each do |query|
        $stderr.puts("Generating docs for #{query.path}")
        html = render_with_layout(generator, :query, {query: query})
        generator.write_file(self, query.output_filename, html)
      end
    end

  end
end
