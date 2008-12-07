
# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base

   include LoginSystem
   include AutoLogin
   include LoginHelpers
   include ThemeEngine

   layout :themed_layout

   before_filter :login_from_cookie
   before_filter :disable_link_prefetching
   

   # If the application throws an exception, this'll send an email to the administrator
   def log_error(exception) 
      super(exception)

      begin
         Mailer.deliver_system_error(
            exception, 
            clean_backtrace(exception), 
            session.instance_variable_get("@data"), 
            params, 
            request.env
         ) if CONFIG['send_emails'] == 1
      rescue 
         growl "Oops, couldn't send the admin an error report: #{exception}"
      end
   end


protected

  # I got your 'Accelerator' right here...
  def disable_link_prefetching
    if request.env["HTTP_X_MOZ"] == "prefetch" 
      logger.debug "prefetch detected: sending 403 Forbidden" 
      render_nothing "403 Forbidden"
      return false
    end
  end

end