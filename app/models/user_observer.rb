class UserObserver < ActiveRecord::Observer
   
   #observe User
   
   def after_create(user)
      begin
         Mailer.deliver_signup(user) if CONFIG[:send_emails]
      rescue
         growl "Couldn't deliver email message. #{$!}"
      end
   end

  
end