ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # ACCOUNT URLS
  map.login 'login', :controller => 'account', :action => 'login'
  map.logout 'logout', :controller => 'account', :action => 'logout'
  map.signup 'signup', :controller => 'account', :action => 'signup'
  map.forgot_pwd 'forgot_password', :controller => 'account', :action => 'forgot_password'
  map.prefs 'prefs', :controller => 'account', :action => 'prefs'
  map.profile 'profile/:id', :controller => 'account', :action => 'profile'
  map.import_export 'import_export', :controller => 'account', :action => 'import_export'


  # TASK URLS
  map.tasklists 'tasklists', :controller => 'tasklist', :action => 'index'
  map.tasklist 'tasklists/:id', :controller => 'tasklist', :action => 'show'  
  map.reorder 'tasklist/reorder', :controller=> 'tasklist', :action => 'reorder'
  map.reorder_taskitems 'tasklist/reorder_taskitems', :controller=> 'tasklist', :action => 'reorder_taskitems'
  map.public 'public/:id', :controller => 'tasklist', :action => 'public'
  map.print 'print/:id', :controller => 'tasklist', :action => 'print'
  map.shared 'shared/:id', :controller => 'tasklist', :action => 'shared'
  map.rss 'rss/:id', :controller => 'tasklist', :action => 'rss'
  map.yaml 'yaml/:id', :controller => 'tasklist', :action => 'yaml'
  map.xml 'xml/:id', :controller => 'tasklist', :action => 'xml'
  map.import 'import', :controller => 'tasklist', :action => 'import'
  map.export 'export', :controller => 'tasklist', :action => 'export'
  map.public_list 'public_list', :controller => 'tasklist', :action => 'public_list'

  map.index 'index', :controller => 'cms', :action => 'index'
  map.index 'terms', :controller => 'cms', :action => 'terms'
  map.index 'about', :controller => 'cms', :action => 'about'
  map.index 'privacy', :controller => 'cms', :action => 'privacy'
  map.index 'FAQ', :controller => 'cms', :action => 'faq'
  map.index 'donate', :controller => 'cms', :action => 'donate'
  map.index 'source', :controller => 'cms', :action => 'source'
  
  map.root :controller => 'cms', :action => 'index'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'  
end