
# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
   
   include LoginHelpers
   
   # Returns a gravatar image URL
   def get_gravatar( email, size=80 )
      gravatar_url( email, "#{ CONFIG['app_url'] }/images/no-avatar.jpg", size )
   end
   
   def get_task_title( task )
      title = h( task.title )
      
      if m = Format::BADGE_PATTERN.match(title)
         title = %|<span class="badge">#{m[1]}</span>#{m[2]}|
      end
      
      textilize_without_paragraph title
   end
   

   
   ###
   ##    DEPRECATED:
   ###
   

   # Creates a FORM tag, just like Rails' form_tag, only adds an on submit 
   # function to disable the form after it's been submitted.
   def open_form_tag( url_for_options = {}, options = {}, *parameters_for_url )
   	options[:onsubmit] = 'disable_submit(null, this);'
   	form_tag( url_for_options, options, *parameters_for_url )
   end

   # Returns the error on an object field...
   def error_on( obj, meth )
   	unless instance_eval("@#{obj}").nil?
   		msg = error_message_on( obj, meth )
   		if msg != "" and not msg.nil?
   			return " #{msg}"
   		end
   	end
   	return ""
   end

   # Returns all the errors on the page for an object...
   def errors_for( obj )
   	error_messages_for( obj ) unless instance_eval("@#{obj}").nil?
   end

   # Returns a label for a field
   def field_label( label, obj, meth, desc=nil )
   	msg = ""#error_on( obj, meth )
   	description = (desc.nil?) ? "" : "<span class=\"field-help\">#{desc}</span>"
   	"<label for=\"#{obj}_#{meth}\">#{label}#{msg}: #{description}</label>"
   end

   # Creates a submit button... it will have an ID of submit_button...
   def submit_button( caption="Save" )
   	"<input id=\"submit_button\" type=\"submit\" value=\"#{caption}\"/>"
   end

   
end
