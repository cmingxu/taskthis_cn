require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base

  # Please change the salt to something else, 
  # Every application should use a different one 
  @@salt = 'task-this!'
  cattr_accessor :salt

  # Authenticate a user. 
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    find(:first, :conditions=>["login = ? AND password = ?", login, sha1(pass)])
  end  
  
  # Changes the password for a user (Custom for TaskTHIS)
  #
  # Example:
  #  @user.change_password( 'new_password' )
  def change_password(pass)
     update_attribute "password", self.class.sha1(pass)
  end
  
  ## Unprotected Customizations...
  attr_reader :preferences
  attr_reader :tasklists_for_sidebar
  
  def preferences
     unless self.prefs.nil?
        return YAML::load( self.prefs )
     else
        return {
           'animate'          => true,
           'show_completed'   => false,
           'show_notes'       => false,
           'show_addtask'     => true,       
           }
     end
  end

  def tasklists_for_sidebar
     self.tasklists.find(:all, :conditions=>'view_in_sidebar = 1')
  end
  
  def create_remembrall_token
     self.remembrall = Digest::SHA1.hexdigest("#{salt}--#{email}--#{Time.now}")
     self.remembrall_expired = 14.days.from_now
     self.save
  end

  protected

  # Apply SHA1 encryption to the supplied password. 
  # We will additionally surround the password with a salt 
  # for additional security. 
  def self.sha1(pass)
    Digest::SHA1.hexdigest("#{salt}--#{pass}--")
  end

  before_create :crypt_password
  
  # Before saving the record to database we will crypt the password 
  # using SHA1. 
  # We never store the actual password in the DB.
  def crypt_password
    write_attribute "password", self.class.sha1(password)
  end
  
  #before_update :crypt_unless_empty
  
  # If the record is updated we will check if the password is empty.
  # If its empty we assume that the user didn't want to change his
  # password and just reset it to the old value.
  def crypt_unless_empty
    if password.empty?      
      user = self.class.find(self.id)
      self.password = user.password
    else
      write_attribute "password", self.class.sha1(password)
    end        
  end  
  
  validates_uniqueness_of :login, :on => :create

  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40

  # Custom for TaskTHIS
  has_many :tasklists, :order=>'position'
    
  # Don't want this to be hacked...
  # So this needs to be explicitly set in the code
  attr_protected :admin
  attr_protected :remembrall
  attr_protected :remembrall_expired


  validates_presence_of :login
  validates_uniqueness_of :email
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password, :on => :create  
  validates_format_of :email, :with =>Format::EMAIL 

  before_create :set_name
    
  def set_name
     self.name = self.login if self.name.nil?
  end

end
