# Include your application configuration below
require_dependency "format"
require_dependency "gravatar"
require_dependency "login_system"
require_dependency "auto_login"
require_dependency "login_helpers"
require_dependency "theme_engine"
require_dependency 'growl'
require_dependency 'json/objects'
require 'yaml'

CONFIG = HashWithIndifferentAccess.new( YAML::load(File.open("#{RAILS_ROOT}/config/app-config.yml")) )
