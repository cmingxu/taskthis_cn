#
# A Mixin that adds some helpers for accessing and testing
# against the currently logged in user...
#
module LoginHelpers

   @@Prefs = {
      'animate'          => true,
      'show_completed'   => false,
      'show_notes'       => false,
      'show_addtask'     => false,
   }
      
   attr_reader :current_user

   #
   # Retrieves the currently logged in user from session
   #
   def current_user
      session[:user]
   end

   #
   # Returns true if a user is logged in
   #
   def user?
      !session[:user].nil?
   end

   #
   # Returns true if a user is logged in and an Admin
   #
   def admin?
      return session[:user].admin? if user?
      false
   end

   #
   # Returns the either the user setting, or the default, depending on w
   # hether a user is logged in or not
   #
   def isPrefTrue( key )
      prefs = session[:user_prefs] || @@Prefs
      prefs[key]
   end
   
   #
   # Tests a given user against the user currently logged in. If they are
   # the same then the return is true
   #
   def is_current_user(user)
      user ==  session[:user]
   end
   
   #
   # Returns a URL to the location specified in the session variable :return_to,
   # or it returns the URL specified by the param default
   #
   def url_back_or_default( default )
      if session[:return_to].nil?
         url_for default
      else
         session[:return_to]
      end
   end
   
end
