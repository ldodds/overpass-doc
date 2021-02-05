module OverpassDoc

  #Wrapper for Overpass query
  class Query

    attr_reader :path, :query, :raw_query, :package

    ANNOTATIONS = {
      :author => {
        :multi => true
      },
      :see => {
        :multi => true
      },
      :tag => {
        :multi => true
      },
      :title => {
        :multi => false
      },
    }

    ANNOTATIONS.each do |var, config|
      attr_reader(var)
    end

    def initialize(path, query, package={})
      ANNOTATIONS.each do |var, config|
        if config[:multi]
          instance_variable_set( "@#{var}", [] )
        else
          instance_variable_set( "@#{var}", "" )
        end
      end
      @path = path
      @query = query
      @raw_query = query
      @title = @path
      @description = ""
      @prefixes = {}

      ["author", "tag"].each do |annotation|
        if package[annotation]
          instance_variable_set( "@#{annotation}", package[annotation])
        end
      end
      parseQuery()
    end

    def output_filename
      return "#{path.gsub(".op", "")}.html"
    end

    def description(html=false)
      if html
        renderer = Redcarpet::Render::HTML.new({})
        markdown = Redcarpet::Markdown.new(renderer, {})
        return markdown.render(@description)
      end
      @description
    end

    def query_string
      CGI::escape( @query )
    end

    private

    def parseQuery
    end
  end

end
