module OverpassDoc

  class Query

    attr_reader :path, :query, :raw_query, :package

    PATTERN = %r{(?<multi>/\*(?<multi_content>(.|\n)*?)?\*/)|(?<error>/\*(.*)?)}

    ANNOTATIONS = {
      :author => {
        :multi => true
      },
      :see => {
        :multi => true
      },
      :tags => {
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
      CGI::escape( @raw_query )
    end

    def extract_annotation(line)
      matches = line.lstrip.match(/^@([a-zA-Z]+) *(.+)$/i)
      return nil unless matches
      return matches[1], matches[2]
    end

    private

    def parseQuery
      match = @raw_query.match(PATTERN)
      return if match.nil?
      if match[:error]
        raise "Invalid query"
      end

      @query = @raw_query.gsub(match[0], "")
      description = false
      description_lines = []

      match[:multi_content].split("\n").each do |line|
        annotation, value = extract_annotation(line)
        if ( annotation )
          config = ANNOTATIONS[ annotation.intern ]
          if config
            if config[:multi]
              val = instance_variable_get("@#{annotation}")
              val << value.strip
            else
              instance_variable_set("@#{annotation}", value.strip)
            end
            description = true
          else
            $stderr.puts("Ignoring unknown annotation: @#{annotation}")
          end
        else
          if (description == false)
            description_lines << line.lstrip
          end
        end
      end
      @description = description_lines.join("\n") unless description_lines.empty?
    end
  end

end
