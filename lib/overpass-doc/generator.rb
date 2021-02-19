module OverpassDoc

  class Generator

    attr_reader :dir, :queries, :package

    def initialize(dir, output_dir, view_dir=nil, asset_dir=nil)
      @dir = dir
      @output_dir = output_dir
      @asset_dir = asset_dir || File.join( File.dirname( __FILE__ ) , "assets")
      @view_dir = view_dir || File.join( File.dirname( __FILE__ ) , "views")
      @package = OverpassDoc::Package.new(@dir)
      @templates = {}
    end

    def run
      copy_assets
      @package.generate(self)
    rescue => e
      puts e
      puts e.backtrace
    end

    def read_template(name)
      return @templates[name] if @templates[name]
      @templates[name] = File.read(File.join(@view_dir, "#{name}.erb"))
      return @templates[name]
    end

    def write_file(package, filename, content)
      if File.dirname(filename) != "."
        FileUtils.mkdir_p File.join(@output_dir, File.dirname(filename))
      end
      File.open(File.join(@output_dir, filename), "w") do |f|
        f.puts(content)
      end
    end

    def copy_assets(asset_dir=@asset_dir)
      $stderr.puts("Copying assets");
      if !File.exists?(@output_dir)
        FileUtils.mkdir_p(@output_dir)
      end
      FileUtils.cp_r( "#{@asset_dir}/.", @output_dir )
    end

  end
end
