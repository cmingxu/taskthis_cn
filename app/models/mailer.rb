class Mailer < ActionMailer::Base

   def signup( user, password='<what you entered on the website>', url=nil, sent_on=Time.now )
      # Email header info
      @recipients = "#{user.email}"
      @from       = CONFIG['email_from'].to_s
      @subject    = "[taskthis] Welcome to taskTHIS!" 
      @sent_on    = sent_on

      # Email body substitutions
      @body["name"] = user.name
      @body["login"] = user.login
      @body["password"] = password
      @body["url"] = url || CONFIG['app_url'].to_s
   end

   def forgot_password( user, password, url=nil, sent_on=Time.now )
      # Email header info
      @recipients = "#{user.email}"
      @from       = CONFIG['email_from'].to_s
      @subject    = "[taskthis] Your New Password" 
      @sent_on    = sent_on

      # Email body substitutions
      @body["name"] = user.name
      @body["login"] = user.login
      @body["password"] = password
      @body["url"] = url || CONFIG['app_url'].to_s
   end

    def new_taskitem( taskitem, sent_on=Time.now )
      # Email header info
      @recipients = "#{taskitem.tasklist.user.email}"
      @from       = CONFIG['email_from'].to_s
      @subject    = "[taskthis] #{taskitem.user.name} added a task to #{taskitem.tasklist.title}" 
      @sent_on    = sent_on

      # Email body substitutions
      @body["taskitem"] = taskitem
      @body["tasklist"] = taskitem.tasklist
      @body["name"] = taskitem.tasklist.user.name
   end

   def system_error( exception, trace, data, params, env, sent_on=Time.now )
      # Email header info
      @recipients = CONFIG['admin_email'].to_s
      @from       = CONFIG['email_from'].to_s
      @subject    = "[taskthis] Exception Details: #{exception}" 
      @sent_on    = sent_on

      # Email body substitutions
      @body["exception"] = exception
      @body["trace"] = trace
      @body["data"] = data
      @body["params"] = params
      @body["env"] = env
   end
   
   def tasklist(recipient, tasklist, all_tasks=true, public_url="", send_on=Time.now)
      # Email header info
      @recipients = recipient
      @from       = "#{tasklist.user.email}" #|| CONFIG['email_from'].to_s
      @subject    = "Tasklist: #{tasklist.title}" 
      @sent_on    = sent_on

      # Email body substitutions
      if all_tasks
         @body[:tasklist] = tasklist
         @body[:tasks] = tasklist.taskitems.find(:all, :order=>'complete ASC')
      else
         @body[:tasklist] = tasklist
         @body[:tasks] = tasklist.taskitems.find(:all, :conditions=>'complete = 0')
      end
      @body[:all_tasks] = all_tasks
      @body[:public_url] = public_url
   end

end
