window.inDrag = false;

var Global = {
   apply_default: function() {
      var rules = {
         '#errorExplanation h2': function(elem) {
            elem.onclick = function() {
               Prefs.handle('animate',
                 function () { // If pref is  true
                    new Effect.DropOut('errorExplanation');
                 },
                 function () { // If pref is false
                    Element.hide('errorExplanation');
                 }
               );
            }
         },
         
         '#profile_readonly': function(elem) {
            Element.cleanWhitespace(elem);
            elem.onmouseover = function() {
               Element.addClassName(this, 'highlight');
               this.firstChild.style.display = '';
            }
            elem.onmouseout = function() {
               if(inDrag) return;
               Element.removeClassName(this, 'highlight');
               this.firstChild.style.display = 'none';
            }            
         },
         
         'H1.tasklist_title': function(elem) {
            Element.cleanWhitespace(elem);
            elem.onmouseover = function() {
               if(inDrag) return;
               if(!document.all) Element.addClassName(this, 'highlight');
               this.firstChild.style.visibility = 'visible';
               Element.addClassName('tasklist_desc', 'highlight')
            }
            elem.onmouseout = function() {
               if(inDrag) return;
               if(!document.all) Element.removeClassName(this, 'highlight');
               this.firstChild.style.visibility = 'hidden';
               Element.removeClassName('tasklist_desc', 'highlight');
            }
         },
         
         '.taskitem': function(elem) {
            Element.cleanWhitespace(elem);
            Element.cleanWhitespace(elem.firstChild);            
            Element.cleanWhitespace(elem.firstChild.firstChild);            
            elem.onmouseover = function() {
               if(inDrag) return;
               if(!document.all) Element.addClassName(this, 'highlight');
               this.firstChild.firstChild.firstChild.style.visibility = 'visible';
            }
            elem.onmouseout = function() {
               if(inDrag) return;
               if(!document.all) Element.removeClassName(this, 'highlight');
               this.firstChild.firstChild.firstChild.style.visibility = 'hidden';               
            }            
            elem.firstChild.firstChild.firstChild.style.visibility = 'hidden';               
         },
         
         'BODY': function(elem) {
            elem.onmouseup = function() {
               if(inDrag) inDrag = false;
            }
         }
      };
      Behaviour.register(rules);
      Behaviour.apply();
   
      if($('errorExplanation'))
      {
         Prefs.handle('animate',
           function () { // If pref is  true
              new Effect.Shake('errorExplanation');
           },
           function () { // If pref is false
              Element.show('errorExplanation');
           }
         );
      }
   }
};

var Tasklist = {
   delete_task_msg: "Deleting this task is permanent.\n\nClick 'OK' to continue with delete.",
   delete_list_msg: "Deleting is permanent.\n\nClick 'OK' to continue with delete.",
   action_postfix: '_tasklist',
   current_action: null,

   do_submit: function(form) {
      // calling form.submit seems to override the onsubmit handler...
      $(form).onsubmit();
   },

   toggle_action: function( action ) {
      if( this.current_action == action )
         this.close_action();
      else
         this.show_action( action );
   },
  
   show_action: function( action ) {
      this.close_action();
      this.current_action = action;
      
      var dom_id = this.current_action + this.action_postfix;
      Prefs.handle('animate',
        function () { // If pref is  true
           new Effect.BlindDown( dom_id );
        },
        function () { // If pref is false
           Element.show( dom_id );
        }
      );

   },
  
   close_action: function() {
      if( this.current_action != null) 
      {
         var dom_id = this.current_action + this.action_postfix;
         Prefs.handle('animate',
           function () { // If pref is  true
              new Effect.BlindUp( dom_id );
           },
           function () { // If pref is false
              Element.hide( dom_id );
           }
         );
         
         this.current_action = null;
      }
   },
   
   delete_tasklist: function( form ) {
     if( confirm(this.delete_list_msg) )
     {
        form.submit();
     }
     else
     {
        this.close_action();
     } 
   },
   
   tasklist_edit: function() {
      Element.hide('page_header');
      Element.show('tasklist_title_form');
      
      var title = $('tasklist_title_container');
      Element.removeClassName(title, 'highlight');
      title.firstChild.style.visibility = 'hidden';
      Element.removeClassName('tasklist_desc', 'highlight');
      Field.focus('tasklist_form_title');
   },
   
   cancel_tasklist_edit: function(id) {
      Element.hide('tasklist_title_form');
      Element.show('page_header');
      Form.reset('taskitem-form-'+ id);
   },
   
   on_task_edit_loading: function(id) {
      Element.hide('tasklist_edit_buttons');
      Element.show('tasklist_edit_loading');
   },

   on_task_edit_complete: function(id, req) {
     // Response is JSON, so we can just use eval to parse it...
     eval("var resp = "+ req.responseText);

     Element.show('tasklist_edit_buttons');
     Element.hide('tasklist_edit_loading');

     if(resp.success)
     {
        $('tasklist_desc').innerHTML = resp.desc
        $('tasklist_title').innerHTML = resp.title
        // The sidebar title...
        /* $('tasklist_'+ id +'_link').innerHTML = resp.title*/

        Element.hide('tasklist_title_form');    
        Element.show('page_header');         
     }
     else
     {
        // Hide the edit form, Reset the form, show message...
        Element.hide('tasklist_title_form');    
        Element.show('page_header');
        Form.reset('tasklist-form-'+ id);
        alert(resp.message);
     }
   },
   
   edit_taskitem: function(taskID) {   
      Element.hide('taskitem_'+ taskID +'_view');
      Element.show('taskitem_'+ taskID +'_edit');
      Field.focus('taskitem_'+ taskID +'_title');
   },

   cancel_edit_taskitem: function(taskID) {
      Element.show('taskitem_'+ taskID +'_view');
      Element.hide('taskitem_'+ taskID +'_edit'); 
      Form.reset('edit-form-taskitem-'+ taskID);
   },
   
   toggle_completed_taskitems: function(img) {
      if(img.alt == 'Show Completed Tasks') 
      {
         img.alt = 'Hide Completed Tasks';
         img.src = '/images/expanded.gif';
         Prefs.handle('animate',
           function () { // If pref is  true
              new Effect.BlindDown('completed_taskitems_container')
           },
           function () { // If pref is false
              Element.show('completed_taskitems_container')
           }
         );
      }
      else 
      {
         img.src = '/images/collapsed.gif';
         img.alt = 'Show Completed Tasks';
         Prefs.handle('animate',
           function () { // If pref is  true
              new Effect.BlindUp('completed_taskitems_container')
           },
           function () { // If pref is false
              Element.hide('completed_taskitems_container')
           }
         );
      }
   },
   
   mark_taskitem_complete: function(cb, taskID) {
      Element.hide('taskitem_'+ taskID +'_check');
      Element.show('taskitem_'+ taskID +'_loading');
      this.do_submit( cb.form.id );
   },
   
   on_mark_taskitem_complete_complete: function( id ) {
      Prefs.handle('animate',
        function () { // If pref is  true
           new Effect.Fade( 'taskitem_'+ id, {
              afterFinish: function() { 
                 Element.remove('taskitem_'+ id);
                 Behaviour.apply();
                 Tasklist.apply_sortable(ul_id, url);
              }
           });
        },
        function () { // If pref is false
           Element.remove('taskitem_'+ id);
           Behaviour.apply();
           Tasklist.apply_sortable(ul_id, url);
        }
      );
   },
   
   mark_taskitem_incomplete: function(cb, taskID) {
      Element.hide('taskitem_'+ taskID +'_complete_check');
      Element.show('taskitem_'+ taskID +'_complete_loading');
           
      this.do_submit( cb.form.id );
   },
   
   on_mark_taskitem_incomplete_complete: function( id ) {
      Prefs.handle('animate',
         function () {
            new Effect.Fade( 'taskitem_'+ id +'_completed', {
               afterFinish: function() { 
                  Element.remove('taskitem_'+ id +'_completed');
                  Behaviour.apply();
                  Tasklist.apply_sortable(ul_id, url);
               }
            });
         },
         function () {
            Element.remove('taskitem_'+ id +'_completed');
            Behaviour.apply();
            Tasklist.apply_sortable(ul_id, url);           
         }
      );
      
      new Effect.Highlight('taskitem_'+ id);
   },
   
   delete_taskitem: function(taskID, url, is_completed) {
      if( confirm(this.delete_task_msg) ) 
      {      
         var dom = (is_completed) ? $('taskitem_'+ taskID +'_completed') : $('taskitem_'+ taskID);
         var TaskID = taskID;
         var opts = {
            onComplete: function(data) {
               if( data.responseText == "SUCCEED" )
               {
                  // basically, the same as: new Effect.DropOut(dom);
                  // only this one will remove the node after the
                  // animation...
                  Prefs.handle('animate',
                    function () { // If pref is  true
                       new Effect.Parallel(
                           [ new Effect.MoveBy(dom, 100, 0, { sync: true }), 
                             new Effect.Opacity(dom, { sync: true, to: 0.0, from: 1.0 } ) ], 
                           { duration: 0.5, 
                            afterFinish: function(effect)
                              { Element.remove(dom); } 
                           });
                    },
                    function () { // If pref is false
                       Element.remove(dom);
                    }
                  );
               }
               else
               {
                  if(is_completed)
                  {
                     Element.hide('taskitem_'+ TaskID +'_complete_check');
                     Element.show('taskitem_'+ TaskID +'_complete_loading');
                  }
                  else
                  {
                     Element.hide('taskitem_'+ TaskID +'_check');
                     Element.show('taskitem_'+ TaskID +'_loading');                     
                  }
                  alert('An error occured trying to delete a task.\n\n'+ data.responseText );
               }
            }
         }

         // turn on the loading animation...
         if(is_completed)
         {
            Element.hide('taskitem_'+ taskID +'_complete_check');
            Element.show('taskitem_'+ taskID +'_complete_loading');
         }
         else
         {
            Element.hide('taskitem_'+ taskID +'_check');
            Element.show('taskitem_'+ taskID +'_loading');                     
         }
         // Send request to server...
         var req = new Ajax.Request(url, opts);         
      }
   },
   
   toggle_notes: function(anc) {
      var notes = $$('.taskitem_notes');
      if(notes[0].style.display == 'none')//anc.innerHTML == "Show Notes") //
      {
        notes.each(function(item){ item.show(); });
//         anc.innerHTML = "Hide Notes";
      }
      else
      {
        notes.each(function(item){ item.hide(); });
//         anc.innerHTML = "Show Notes";
      }
   },
   
   on_edit_loading: function(id) {
      Element.hide('taskitem_'+ id +'_edit_buttons');
      Element.show('taskitem_'+ id +'_edit_loading');
      
      Form.disable('edit-form-taskitem-'+ id);
   },
   
   on_edit_complete: function(id) {
      new Effect.Highlight('taskitem_'+ id);
      Behaviour.apply();
      Tasklist.apply_sortable(ul_id, url);
   },
   
   on_new_taskitem_loading: function(id) {
      Form.reset('taskitem-form-'+ id);
      Form.focus_first('taskitem_new_title');
      Element.show('new_taskitem_loading');
   },
   
   on_new_taskitem_complete: function(id) {
      Element.hide('new_taskitem_loading');
      new Effect.Highlight('tasklist_'+ id +'_items');
      Behaviour.apply();
      Tasklist.apply_sortable(ul_id, url);
   },
   
   show_new_taskitem_form: function() {
      Element.hide('tasklist-new-task-link');
      Element.show('tasklist-new-task-form');
      Field.focus('taskitem_new_title');
   },

   hide_new_taskitem_form: function() {
      Element.hide('tasklist-new-task-form');
      Element.show('tasklist-new-task-link');
   },
   
   on_sharing_loading: function() {
      Element.hide('sharing_buttons');
      Element.show('sharing_loading');
   },
   on_sharing_complete: function(req) {
      Element.hide('sharing_loading');
      Element.show('sharing_buttons');
      
      eval("var resp = "+ req.responseText);

      if(resp.success)
         this.close_action();
      else
         alert( resp.message)
         
      if( resp.is_public )
         Element.show('RSS')
      else
         Element.hide('RSS')      
   },
   
   on_send_loading: function() {
      Element.hide('send_action_buttons');
      Element.show('send_loading');
   },
   on_send_complete: function(req) {
      eval("var resp = "+ req.responseText);
      
      Element.hide('send_loading');      
      Element.show('send_action_buttons');

      alert( resp.message );
      
      if(resp.success) {
         this.close_action();
         Form.reset('tasklist-send-form');
      }
   },
    
   apply_sortable: function( ul, url )
   {
      Sortable.create( ul, {
         handle:'handle', 
         onUpdate: function(){
            new Ajax.Updater( 
               'page_status_area', 
               url, 
               {
                  asynchronous:true, 
                  evalScripts:true, 
                  onComplete: function(request) {
                     Prefs.handle('animate',
                        function () {
                           new Effect.Appear('page_status_area',{});
                           setTimeout('new Effect.Fade(\'page_status_area\')', 3000)
                        },
                        function () {
                           Element.show('page_status_area');
                           setTimeout('Element.hide(\'page_status_area\')', 3000)                           
                        }
                     );
                  },
                  onLoading: function(request){
                     inDrag=false
                  }, 
                  parameters:Sortable.serialize(ul)
               })
            }
         }
      )
   }
};

var Profile = {
  on_tasklists_save_loading: function() {
     Element.hide('save_buttons');
     Element.show('tasklist_loading');
  },

  on_tasklists_save_complete: function(req) {
     eval("var resp ="+ req.responseText);
     
     if(!resp.success)
      alert('oops')
     
     Element.show('save_buttons');
     Element.hide('tasklist_loading');
  },
  
  hide_buttons:function() {
     Element.hide('save_buttons');
     Element.show('loading');  
  },
  
  on_import: function() {
     Element.hide('import_button');
     Element.show('import_loading');
     Field.disable('export_button')
  },
  on_export: function() {
     Element.hide('export_button');
     Element.show('export_loading');
     
     Field.disable('import_button');
  },
  
  on_profile_loading: function() {
     Element.hide('profile_button');
     Element.show('profile_loading');     
  },
  on_profile_complete: function(req) {
     eval("var resp = "+ req.responseText);
     
     Element.show('profile_button');
     Element.hide('profile_loading');   
     
     if(resp.success) {
        $('profile_name').innerHTML = resp.name;
        $('profile_email').innerHTML = resp.email;   
        this.cancel_edit_profile();
     } else {
        alert( resp.msg );
     }     
  },
  
  edit_profile: function() {
     Element.hide('profile_readonly');
     Element.show('profile_form');
     Element.removeClassName('profile_readonly', 'highlight');
     Field.focus('user_name')
  },
  cancel_edit_profile: function() {
     Element.show('profile_readonly');
     Element.hide('profile_form');
  }
};

var Prefs = {

   // Execute 'funcTrue', if the pref is true, otherwise it execute 'funcFalse'
   handle: function(pref, funcTrue, funcFalse) {
      if( user_prefs[pref] )
         funcTrue();
      else
         funcFalse();         
   },
   
   on_save_loading: function() {
      Element.hide('save_buttons');
      Element.show('prefs_loading');
   },

   on_save_complete: function(req) {
      eval("var resp = "+ req.responseText);
      if(!resp.success) {
         alert( resp.msg );
      }
      Element.hide('prefs_loading');      
      Element.show('save_buttons');
   }
};

var Main = {
   
   show_create_new_tasklist: function() {
      Prefs.handle('animate',
        function () { // If pref is  true
           new Effect.BlindUp('new_task_button');
           new Effect.BlindDown('new_tasklist_panel');
        },
        function () { // If pref is false
           Element.hide('new_task_button');
           Element.show('new_tasklist_panel');
        }
      );
   },
   
   hide_create_new_tasklist: function() {
      Prefs.handle('animate',
        function () { // If pref is  true
           new Effect.BlindDown('new_task_button');
           new Effect.BlindUp('new_tasklist_panel');
        },
        function () { // If pref is false
           Element.hide('new_tasklist_panel');
           Element.show('new_task_button');
        }
      );
   },
   
   on_tasklist_reorder_complete: function() {
      Prefs.handle('animate',
        function () { // If pref is  true
           new Effect.Appear('list_reorder_results',{});
           setTimeout('new Effect.Fade(\'list_reorder_results\')', 3000)
        },
        function () { // If pref is false
           Element.show('list_reorder_results');
           setTimeout("Element.hide('list_reorder_results')", 3000)
        }
      );
   }
   
}

var Public = {
  init_nav: function() {
    var cookies = new CookieJar();
    if(cookies.getRaw('remembrall')) {
      // Logged in... probably
      $('public_nav').hide();
      $('non_public_nav').show();
    } 
  }
}
