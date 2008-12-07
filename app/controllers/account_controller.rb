require 'digest/sha1'

class AccountController < ApplicationController
#  model   :user
#  observer :user_observer

  #
  # The Login Page. It posts to itself wit the login information
  #
  def login
    return redirect_to( :action=>'welcome' ) unless current_user.nil?
    case request.method
      when :post
      if user = User.authenticate(params[:user_login], params[:user_password])
         handle_login( user )
         if params[:remember_me]
            create_remembrall( current_user )
         end
         flash['notice']  = "Login successful"  
         redirect_back_or_default tasklists_path
      else
        flash.now['notice']  = "Login unsuccessful"
        @login = params[:user_login]
      end
    end
  end

  #
  # The registration page. It posts to itself the signup info
  #
  def signup
    @user = User.new(params[:user])
    
    @user.prefs = {
       'animate'          => true,
       'show_completed'   => false,
       'show_notes'       => false,
       'show_addtask'     => false,       
    }.to_yaml

    if request.post? and @user.save
      handle_login @user
      
      flash['notice']  = "Signup successful"
      redirect_back_or_default tasklists_path
    end      
  end
  
  #
  # The Logout command. Kills the session variable, the 'remember me' 
  # cookie, and redirects to the login page
  #  
  def logout
    session[:user] = nil
    kill_autologin_cookie
    redirect_to :action=>'login'
  end
  
  # 
  # The Welcome page. This is the page that the login sends you to.
  #
  def welcome
     redirect_to tasklists_path
  end
  

  #
  # The Profile Page. It will show two different things based on whether
  # an ID is sent. If it is, then it's the public profile of the user
  # with the user_id of ID. Otherwise, it's the currently logged in
  # user's profile.
  #
  # When it's a public profile, only a user's tasklists that are marked as
  # public will be visible in the tasklist. 
  #
  def profile
     if( params[:id] )
        @is_public = true
        @user = User.find( params[:id] )
        @user_tasklists = @user.tasklists.find(:all, :conditions=>'is_public=1')
        @shared_tasklists = nil
     else
        return redirect_to( login_url ) if current_user.nil?

        @is_public = false
        @user = current_user
        @user_tasklists = @user.tasklists.find(:all)
        # Todo: Get all the lists that this user is marked as a sharer
        @shared_tasklists = nil
     end
     @mytasklists = current_user.tasklists unless current_user.nil?
  end
  
  #
  # The Delete action. It must be have the ID posted to it -- even if it's
  # the current_user.
  #
  # The current_user can only delete theirself, unless they're an admin.
  #
  def delete
     if request.post?
        is_current_user = (params[:id] == current_user.id) ? true : false
        if is_current_user or is_admin?
           @user = User.find(params['id'])
           @user.destroy
           
           return redirect_to( logout_url ) if is_current_user
           
           redirect_back_or_default :action => "welcome"
        end
     else
        redirect_back_or_default :action => "welcome"
     end
  end

  #
  # The Preferences (settings) Page
  #
  def prefs
     return redirect_to( login_url ) if current_user.nil?
     
     @mytasklists = current_user.tasklists
  	  @user = current_user
  	  @prefs = session[:user_prefs]
  	  if request.post?
  	     @user.attributes = params['user']
  	     
  	     if @user.save
  	        flash['notice']  = "User preferences saved successfully"
  			  redirect_to :controller=>'tasks', :action => "list"
  	     end
  	  end
  end
  
  #
  # Update Profile Action. his action for use with AJAX only
  #
  def update_profile
     return render( :text=>{:success=>false, :msg=>"You are not logged in!"}.to_json ) if current_user.nil?     
     return render( :text=>{:success=>false, :msg=>"Wrong User ID #{params[:id]}!=#{current_user.id}"}.to_json ) if params[:id].to_i != current_user.id

  	  if request.post?
  	     @user = current_user
  	     
  	     @user.attributes = params['user']

        return render( :text=>{:success=>true, :msg=>'Success', :name=>@user.name, :email=>@user.email}.to_json ) if @user.save
  	  end

  	  render :text=>{:success=>false, :msg=>'Failed to save'}.to_json 
  end
  
  # 
  # Update Prefs action. This action for use with AJAX only
  #
  def update_prefs
     return render( :text=>{:success=>false, :msg=>"You are not logged in!"}.to_json ) if current_user.nil?     
     return render( :text=>{:success=>false, :msg=>"Wrong User ID #{params[:id]}!=#{current_user.id}"}.to_json ) if params[:id].to_i != current_user.id
     
     if request.post?
        @user = current_user
     
        params[:prefs].each_key do |key|
           session[:user_prefs][key] = (params[:prefs][key].to_i == 1)
        end
     
        @user.prefs =  session[:user_prefs].to_yaml
     
        return render( :text=>{:success=>true, :msg=>'Success'}.to_json ) if @user.save
     end
     
     render :text=>{:success=>false, :msg=>'Failed to save'}.to_json 
  end
  
  #
  # The Preferences (import/export) Page.
  #
  def import_export
     return redirect_to( login_url ) if current_user.nil? 
  end
  
  #
  # The Preferences (change password) Page. This page posts to itself the
  # new password information
  #
  def change_password
     return redirect_to( login_url ) if current_user.nil?
     
     @mytasklists = Tasklist.find_all_by_user_id session[:user].id
     if request.post?
        @user = current_user
        @user.attributes = params[:user]
        if @user.save
           @user.change_password( @user.password )
           session[:user] = @user
           flash['notice'] = "Password updated successfully"
           redirect_to :controller=>'account', :action=>'change_password'
        end
     end
  end

  #
  # The Forgot Password Page. It posts back to itself with the user's email
  #
  def forgot_password
     if request.post?
        if params['user_email'].nil?
           @message = "Please enter a valid email address"
        else
           user = User.find_by_email params['user_email']
           if user.nil?
              @message = "Please enter a valid email address"
           else
              pwd = Digest::SHA1.hexdigest("-task-this!-#{Time.now}")[0,10]
              begin
                 Mailer.deliver_forgot_password(user, pwd)
     	           user.change_password pwd
  	              flash['message'] = "An new password has been sent to #{params['user_email']}"
  	              redirect_to :action=>'login'
  	           rescue
  	              @message = "Server Error: Email could not be sent <!-- #{$!} -->"
  	           end
  	        end
        end
     end
  end

end
