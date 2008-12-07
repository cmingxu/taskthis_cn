# #!/usr/bin/env ruby
# 
# #require 'rubygems'
# #require 'webgen'
# #require 'webgen/plugins/tags/tag_processor'
# #module Tags
# 
#    class VariableTag < Tags::DefaultTag
# 
#       param 'attr', 'MISC', 'The attribute to fetch.'
#       set_mandatory 'attr', true
#       
#       infos( :name => 'Custom/VariableTag',
#              :summary => "Custom tag for setting variables." )
# 
#       register_tag( 'var' )
#       
#       
#       
#       def process_tag( tag, chain )
#       #   data[ param('attr').to_s ].to_s
#         param( param('attr') ).to_s
#       end
#       
#       
#     protected
#     
#       def data
#         # @data ||= @@configFileData['VariableTags']
#         # @data
#         self.class.config
#       end
# 
#    end
# 
# #end
