
class TaskitemObserver < ActiveRecord::Observer
  
  # Currently unused!!!
   
   def after_create(taskitem)
     
      if taskitem.tasklist.do_notification? and taskitem.user != taskitem.tasklist.user and CONFIG[:send_emails]
         begin
            Mailer.deliver_new_taskitem( taskitem )  
            growl "Task was created, and an email as sent for: #{taskitem.title}"
         rescue 
            growl "Couldn't deliver email message. #{$!}"
         end
      end
      
   end

end