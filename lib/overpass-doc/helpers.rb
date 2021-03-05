module OverpassDoc
  module Helpers

    def asset_path(resource)
      resource = resource[1..-1] if resource.start_with?("/")
      if child?
        "../" + resource
      else
        resource
      end
      # if File.path(@dir) == @generator.dir
      #   resource
      # else
      #   dirs = File.path(@dir).split("/").size - 2
      #   return Array.new(dirs, "../").join + resource
      # end
    end

    def script_link(resource)
      '<script src="' + asset_path(resource) + '" type="text/javascript"></script>'
    end

    def stylesheet(resource)
      '<link rel="stylesheet" href="' + asset_path(resource) + '">'
    end

  end
end
