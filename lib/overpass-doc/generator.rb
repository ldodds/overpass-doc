module OverpassDoc

  class Generator

    attr_reader :dir, :queries, :package, :output_dir

    def initialize(dir, output_dir, view_dir=nil, asset_dir=nil)
      @dir = dir
      @output_dir = output_dir
      @templates = {}
      @asset_dir = asset_dir || File.join( File.dirname( __FILE__ ) , "assets")
      @view_dir = view_dir || File.join( File.dirname( __FILE__ ) , "views")
    end

    def run
      @package = OverpassDoc::Package.new(self, @dir)
      copy_assets
      @package.generate
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
      if !File.exist?(File.join(@output_dir, package.path))
        FileUtils.mkdir_p File.join(@output_dir, package.path)
      end
      File.open(File.join(@output_dir, File.path(package.dir).dup.gsub(@dir, ""), filename), "w") do |f|
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
