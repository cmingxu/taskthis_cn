
class TasklistController < ApplicationController

#  observer :taskitem_observer

   before_filter :login_required, :except=>['public_list', 'public', 'rss', 'print']

   layout :themed_layout, :except=>['print', 'yaml', 'rss', 'xml']

   #
   # The default 'editable' view for tasklists
   #
   def show
      @tasklist = Tasklist.find( params[:id] )
      
      if @tasklist.user != current_user
         redirect_to public_url( :id=>params[:id] )
      end
      
      @complete_tasks =  @tasklist.taskitems.find( :all, :conditions=>'complete = 1')
      @incomplete_tasks =  @tasklist.taskitems.find( :all, :conditions=>'complete = 0')
   end
   
   #
   # The public view of a tasklist
   #
   def public
      @tasklist = Tasklist.find( params[:id] )      
      
      unless @tasklist.is_public?
         redirect_to profile_url
      end
      
      @complete_tasks =  @tasklist.taskitems.find( :all, :conditions=>'complete = 1')
      @incomplete_tasks =  @tasklist.taskitems.find( :all, :conditions=>'complete = 0')
   end
   
   def index
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
   # A non-published (meaning it's not linked to anywhere) directory of all the
   # public tasklists... It's probably going to go away very soon!
   #
   def public_list
      @tasklists = Tasklist.find(:all, :conditions=>'is_public = 1')
   end
   
   #
   # The view for a tasklist you are a contributor on.
   #
   def shared
      #yeah... it's coming
   end
   
   #
   # The print view for tasklists
   #
   def print
      @tasklist = Tasklist.find( params[:id] )      

      unless @tasklist.is_public? or @tasklist.user == current_user
         redirect_to profile_url
      end
      
      render :action=>'print', :layout=>theme_layout_path('print')
   end

   #
   # Displays all of the user tasks for the given tasklist, if it's marked public.
   #
   # Right now, it uses a format like tada-lists... If a task is completed, it adds
   # the text 'Completed: ' to the title, or 'Added: ' if it's  incomplete. I don't 
   # really use RSS with tasklists -- does this really make sense?
   #
   def rss
      @tasklist = Tasklist.find( params[:id] )      

      redirect_to profile_url unless @tasklist.is_public?
      
      @tasks = @tasklist.taskitems.find(:all, :order=>'updated_on')
      @complete_tasks =  @tasklist.taskitems.find( :all, :conditions=>'complete = 1')
      @incomplete_tasks =  @tasklist.taskitems.find( :all, :conditions=>'complete = 0')
   end
   
   #
   # Export all of the current user's tasklists to XML
   #
   def xml
      @tasklists = current_user.tasklists
   end
   
   #
   # Export all of the current user's tasklists to YAML
   #
   def yaml
      tasklists = []
      current_user.tasklists.each do | tl |
         tasklist = {}
         tasklist['title'] = tl.title
         tasklist['position'] = tl.position
         tasklist['description'] = tl.description

         items = []
         tl.taskitems.each do | ti |
            task = {}
            task['title'] = ti.title
            task['notes'] = ti.notes
            task['complete'] = ti.complete
            task['position'] = ti.position
            #task['due_on'] = ti.due_on

            items << task
         end

         tasklist['tasks'] = items

         tasklists << tasklist
      end

      @response.headers["content-type"] = "text/plain"

      render :text=>tasklists.to_yaml
   end
   
   #
   # A switch -- it's posted to from account_controller::import_export
   #
   def export
      if not params[:export_type].nil? and params[:export_type] == "XML"
         redirect_to xml_url
      else
         redirect_to yaml_url
      end
   end
   
   #
   # Imports the posted YAML and creates tasklists.
   #
   def import
      if request.post?
         
         new_tasklist = YAML::load( params[:yaml_data] )
      
         new_tasklist.each do |tasklist|
            new_tl = Tasklist.new
            tl = Tasklist.find_by_title_and_user_id( tasklist['title'], current_user.id )

            unless tl.nil?
               tasklist['title'] += " Copy 2" 
            end
         
            new_tl.user = current_user
            new_tl.title = tasklist['title']
            new_tl.description = tasklist['description']
            new_tl.position = tasklist['position']
         #   puts ">>> #{tasklist['title']}"
         
            if new_tl.save
               tasklist['tasks'].each do |task|
                  new_ti = Taskitem.new
                  new_ti.tasklist = new_tl
                  new_ti.user = current_user
                  new_ti.title = task['title']
                  new_ti.notes = task['notes']
                  new_ti.position = task['position']
                  new_ti.complete = task['complete']
                  new_ti.save
          #        puts "-----> #{task['title']}"
               end
            end
         end
            
         redirect_to profile_url
      else
         redirect_to import_export_url
      end
   end
   
   
   # ------------------------------------------------------------

   #
   # Create a Tasklist action. This is posted to from the top of
   # the sidebar (it can be called from anywhere)
   #
   def create
      if request.post?
         listname = params[:task_list_name]
         logger.info("\n\nTrying to create task list: #{listname}")
         tl = Tasklist.new({
          :title => listname,
          :user_id => current_user.id
         })
         logger.info('About to save it...')
         tl.save
         
         logger.info("#{tl.to_yaml}\n\n")
         redirect_to tasklist_url( :id=>tl.id )
      else
         render_nothing "403 Forbidden"
      end
   end

   #
   # Edit Tasklist -- for AJAX use only, returns JSON formatted info object.
   #
   def edit
      if request.post?
         @tasklist = Tasklist.find(params['id'])
         redirect_to profile_url if @tasklist.user != current_user

         @tasklist.attributes = params["tasklist"]
      
         if @tasklist.save
            info = {
               :success => true,
               :message => 'Tasklist was successfully updated.',
               :title   => @tasklist.title,
               :desc    => (@tasklist.description_html || '').gsub('"', '\''), # Stupid hack -- json isn't encoding quotes correctly! (it's a problem if a link is in the description)
               :is_public   => @tasklist.is_public?,
            }
            render :text=>info.to_json
         else
            info = {
               :success => false,
               :message => 'Tasklist was not saved!'
            }
            render :text=>info.to_json         
         end
      else
         render_nothing "403 Forbidden"
      end
   end

   #
   # Delete Tasklist. Is posted to from the index action
   #
   def delete
      if request.post?
         tl = Tasklist.find(params['tasklist_id'])
         if tl.user == current_user
            tl.destroy
         end
        redirect_to profile_url
     else
        render_nothing "403 Forbidden"
     end
   end
   
   #
   # Tasklist Reorder action -- for AJAX use only, returns status string.
   #
   # This is called from the tasklist in the sidebar when the tasklists have been
   # rearranged (drag n drop, no less!)
   #
   def reorder
      if request.post?
         tasklists = params[:user_tasklists]
         success = 0

         tasklists.each_with_index do |id, i|
            tasklist = Tasklist.find(id)
            tasklist.position = i
            success = success +1 if tasklist.save
         end

         if tasklists.length == success
            render :text=>"Updated Sort Order"
         else
            render :text=>"Some Items Weren't Saved"
         end
      else
         render_nothing "403 Forbidden"
      end
   end
   
   #
   # Send Tasklist action  -- for AJAX use only, returns JSON formatted info object.
   #
   # Accepts a list of emails, seperated by newlines (\n). But it will only send
   # 10 at a time. If any more than 10 are sent, the rest are ignored.
   #
   def send_tasklist
      if request.post?
         tasklist = Tasklist.find(params[:id])

         return render( :text=>{ :success=>false, :message=>"You may only send your own tasklists" }.to_json() ) if current_user != tasklist.user

         emails = params[:recipients].split
         all_tasks = (params[:include_completed] == "1") ? true : false
      
         valid_emails = []
         sent_emails = []
         failed_emails = []
      
         emails.each_with_index do |email, i|
            break if i == 10 # don't want to be a complete spam center!
            valid_emails << email.strip if (email.strip =~ Format::EMAIL)
         end
      
         valid_emails.uniq! # we don't want duplicate email addresses...
      
         valid_emails.each do |email|
            begin
               Mailer.deliver_tasklist( email, tasklist, all_tasks, public_url(:id=>tasklist.id) ) 
            rescue 
               failed_emails << email
               puts ">>>>>>>>> #{$!}"
            else
               sent_emails << email
            end
         end
         if failed_emails.length > 0
            message = "There were errors while mailing this tasklist.\n\n"
            message += "Email(s) were sent to:\n - #{sent_emails.join("\n - ")}\n\n" if sent_emails.length > 0
            message += "Email(s) were not sent to:\n - #{failed_emails.join("\n - ")}"
            render :text=>{ 
               :success=>false, 
               :message=>message,
               :failed_emails=>failed_emails,
               :sent_emails=>sent_emails
            }.to_json
         else
            render :text=>{ 
               :success=>true,
               :message=>"Email(s) were sent to:\n - #{sent_emails.join("\n - ")}",
               :sent_emails=>sent_emails
            }.to_json
         end
      else
         render_nothing "403 Forbidden"
      end
   end
   
   #
   # Tasklist View In Sidebar Update Action -- for AJAX use only, returns JSON formatted info object.
   #
   # This is called from the profile page
   #
   def update_tasklist_vis
      if request.post?
         tasklists = params[:tasklist]
      
         tasklists.each_key do |id|
            tasklist = Tasklist.find(id)
            if tasklist.user == current_user
               tasklist.view_in_sidebar = tasklists[id]['view_in_sidebar']
               tasklist.save
            end
         end
      
         render :text=>{:success=>true}.to_json
      else
         render_nothing "403 Forbidden"
      end
   end
   
   # ------------------------------------------------------------
   
   #
   #  Taskitem Reorder -- for AJAX use only, returns status string.
   #
   def reorder_taskitems
      if request.post?
         success = 0
         total = 0
         params.each_key do |key|
            #FIXME A woeful hack -- I use this method because I wanted to use the built in sortable_element tag...
            if key[0,8] == 'tasklist'

               params[key].each_with_index do |id, i|
                  taskitem = Taskitem.find(id)
                  taskitem.position = i
                  success = success +1 if taskitem.save
               end
               total = params[key].length

            end
         end

         if total == success
            render :text=>"Updated Sort Order"
         else
            render :text=>"Some Items Weren't Saved"
         end
      else
         render_nothing "403 Forbidden"
      end
   end
   
   #
   # Taskitem Delete -- for AJAX use only, returns status string.
   #
   def destroy_taskitem
      if request.post?
         ti = Taskitem.find( params['id'] )
         if is_current_user(ti.user) and ti.destroy
            render :text=>"SUCCEED"
         else
            render :text=>"FAIL"
         end
      else
         render_nothing "403 Forbidden"
      end
   end
   
   #
   # Complete Taskitem -- for AJAX use only, returns returns partial HTML (taskitem_complete).
   #
   def mark_taskitem_complete
      if request.post?
         ti = Taskitem.find( params['taskitem_id'] )
         ti.toggle_complete if ti.tasklist.user == current_user

         #TODO: allow_delete will defer based on sharing...
         render :partial=>'taskitem_complete', :locals=>{ :taskitem=>ti, :allow_delete=>true, :allow_edit=>true }
      else
         render_nothing "403 Forbidden"
      end
   end
   
   #
   # Uncomplete Taskitem -- for AJAX use only, returns partial HTML (taskitem_incomplete).
   #
   def mark_taskitem_incomplete
      if request.post?
         ti = Taskitem.find( params['taskitem_id'] )
         ti.toggle_complete if ti.tasklist.user == current_user

         #TODO: allow_delete/allow_edit will defer based on sharing...
         render :partial=>'taskitem_incomplete', :locals=>{ :taskitem=>ti, :is_update=>false, :allow_delete=>true, :allow_edit=>true }
      else
         render_nothing "403 Forbidden"
      end
   end
   
   #
   # Taskitem Update -- for AJAX use only, returns partial HTML (taskitem_incomplete).
   #
   def edit_taskitem
      if request.post?
         id = params['taskitem_id']
         ti = Taskitem.find(id)
         if ti.tasklist.user == current_user
            ti.attributes = params["taskitem"][id]
            ti.save
         end

         #TODO: allow_delete/allow_edit will defer based on sharing...
         render :partial=>'taskitem_incomplete', :locals=>{ :taskitem=>ti, :is_update=>true, :allow_delete=>true, :allow_edit=>true }
      else
         render_nothing "403 Forbidden"
      end
   end

   #
   # Taskitem Create -- for AJAX use only, returns partial HTML (taskitem_incomplete).
   #
   def create_taskitem
      if request.post?
         tl = Tasklist.find( params['tasklist_id'] )
         ti = Taskitem.new( params['taskitem']['new'] )
         ti.tasklist = tl
         ti.user = current_user
         ti.save

         #TODO: allow_delete/allow_edit will defer based on sharing...
         render :partial=>'taskitem_incomplete', :locals=>{ :taskitem=>ti, :is_update=>false, :allow_delete=>true, :allow_edit=>true }
      else
         render_nothing "403 Forbidden"
      end
   end
end