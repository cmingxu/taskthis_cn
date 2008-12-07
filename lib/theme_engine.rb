# This needs to be included in you application.rb
module ThemeEngine

   attr_accessor :current_theme

   # You need to override this!
   # This should return the current theme
   def self.current_theme
     'default'
   end

   # default layout helper
   def themed_layout( default_layout="main", theme=ThemeEngine.current_theme )
      theme_layout_path( default_layout, theme )
   end

   # Responsible for the path to the themed layout file...
   def theme_layout_path( layout_name, theme=ThemeEngine.current_theme )
      "themes/#{theme}/#{layout_name}"
   end

end

#
# These are theme helper tags
#
module ActionView
   module Helpers
      module AssetTagHelper

         # returns the public path to a theme stylesheet
         def theme_stylesheet_path( source="theme", theme=ThemeEngine.current_theme )
            compute_public_path(source, "themes/#{theme}", 'css')
         end

         # returns the path to a theme image
         def theme_image_path( source, theme=ThemeEngine.current_theme )
            compute_public_path(source, "themes/#{theme}/images", 'js')
         end

         # returns the path to a theme javascript
         def theme_javascript_path( source, theme=ThemeEngine.current_theme )
            compute_public_path(source, "themes/#{theme}/javascripts", 'js')
         end

         # This doesn't support overriding the Theme -- it will use the current theme
         def theme_stylesheet_link_tag(*sources)
            sources << 'theme'
            sources.uniq!
            options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }
            sources.collect { |source|
               source = theme_stylesheet_path(source)
               tag("link", { "rel" => "Stylesheet", "type" => "text/css", "media" => "screen", "href" => source }.merge(options))
            }.join("\n")
         end

      end 
   end
end