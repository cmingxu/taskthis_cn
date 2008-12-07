#
# AutoLogin Mixin... Should be included in the main AplicationController (application.rb)
#
module AutoLogin

   # Implements the 'Remember Me' functionality. If the session doesn't have a user
   # we'll look for the cookie with the login info -- if it's there, then we'll login!
   #
   # This should be used with as a filter (perhaps in application.rb)
   #
   # Example:
   #  before_filter = :login_from_cookie
   #
   def login_from_cookie
      user = User.find_by_remembrall( cookies[:remembrall] ) if cookies[:remembrall] and session[:user].nil?
      if user and active_remembrall? user
         handle_login user
      end
   end
   
   #
   # The actual login process
   #  1) Add user object to session
   #  2) Set the last_login time
   #  3) Add the user preferences to session
   #
   def handle_login( user )
      return nil if user.nil?
      session[:user] = user
      session[:user].last_login = Time.now
      session[:user].save
      session[:user_prefs] = YAML::load(current_user.prefs)
   end
   
   #
   # Returns true if the user has an 'active' remembrall
   #
   def active_remembrall?( user )
      return Time.now < user.remembrall_expired unless user.remembrall_expired.nil?
      false
   end
   
   #
   # Creates a new remembrall if the old one has expired, and sets the autologin cookie
   #
   def create_remembrall( user )
      user.create_remembrall_token unless active_remembrall? user
      set_autologin_cookie( user )
   end
   
   #
   # Set the autologin cookie
   #
   def set_autologin_cookie( user )
      cookies[:remembrall] = { :value=>user.remembrall, :expires=>user.remembrall_expired } if active_remembrall? user    
   end
   
   #
   # Update the value of the autologin cookie
   #
   def update_autologin_cookie( user )
      if cookies[:remembrall]
         cookies[:remembrall] = user.remembrall
      end
   end
   
   #
   # Nuke the autologin cookie
   #
   def kill_autologin_cookie
      cookies.delete :remembrall
   end
end

